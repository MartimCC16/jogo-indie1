# ============================================================================
# mapa_base.gd  —  O que TODO mapa do jogo faz (vila, floresta, picos...)
# ----------------------------------------------------------------------------
# O script de cada mapa começa com "extends MapaBase" e herda tudo isto:
#   - coloca a Lia no lugar certo:
#       1) voltando de batalha  -> onde ela estava;
#       2) vindo de outro mapa  -> no marcador de entrada (Marcadores/<nome>);
#       3) senão                -> no marcador "InicioLia";
#   - limita a câmera às bordas do mapa;
#   - faz o Sir Eco seguir a Lia (se ele já despertou);
#   - mostra o nome da região.
#
# Estrutura esperada da cena (copie a da floresta para criar um mapa novo):
#   Mapa (MapaDeTexto)  Marcadores  Entidades(Arvores, Lia, SirEco...)
#   Saidas  Clima  Interface/NomeRegiao
#
# Para fazer algo especial num mapa, sobrescreva _ao_entrar() no script dele.
# ============================================================================
class_name MapaBase
extends Node2D

## Texto que aparece quando a cena começa.
@export var nome_da_regiao := ""

@onready var mapa: MapaDeTexto = $Mapa
@onready var lia: Jogador = $Entidades/Lia
@onready var sir_eco: Seguidor = get_node_or_null("Entidades/SirEco")


func _ready() -> void:
	# Obs.: o _ready() dos filhos roda ANTES do pai, então o mapa já existe aqui.
	_posicionar_lia()
	lia.limitar_camera(mapa.retangulo_em_pixels())
	_preparar_sir_eco()
	_ao_entrar()


## Chamado quando o mapa termina de carregar. Os mapas podem trocar isto.
func _ao_entrar() -> void:
	mostrar_nome_regiao()


func _posicionar_lia() -> void:
	if EstadoJogo.posicao_retorno != null:
		lia.global_position = EstadoJogo.posicao_retorno
		EstadoJogo.posicao_retorno = null
		return
	var nome_marcador := "InicioLia"
	if EstadoJogo.entrada_alvo != "":
		nome_marcador = EstadoJogo.entrada_alvo
		EstadoJogo.entrada_alvo = ""
	var marcador := get_node_or_null("Marcadores/" + nome_marcador) as Node2D
	if marcador:
		lia.global_position = marcador.global_position
	else:
		push_warning("Marcador '%s' não existe neste mapa." % nome_marcador)
	if EstadoJogo.direcao_entrada >= 0:
		lia.direcao_olhar = EstadoJogo.direcao_entrada as Jogador.Direcao
		EstadoJogo.direcao_entrada = -1


## Se o Sir Eco já despertou, ele aparece atrás da Lia e passa a segui-la.
func _preparar_sir_eco() -> void:
	if sir_eco == null:
		return
	if not EstadoJogo.tem_flag("eco_despertou"):
		sir_eco.hide()
		return
	sir_eco.global_position = lia.global_position - lia.vetor_olhar() * 14.0
	sir_eco.seguir(lia)


## Mostra o nome da região no alto da tela e some devagar.
func mostrar_nome_regiao() -> void:
	var rotulo := get_node_or_null("Interface/NomeRegiao") as Label
	if rotulo == null or nome_da_regiao == "":
		return
	rotulo.text = nome_da_regiao
	rotulo.modulate.a = 0.0  # começa invisível (a = transparência)
	# Um "tween" anima uma propriedade ao longo do tempo, passo a passo:
	var tween := create_tween()
	tween.tween_property(rotulo, "modulate:a", 1.0, 0.6)  # aparece
	tween.tween_interval(2.0)                              # espera
	tween.tween_property(rotulo, "modulate:a", 0.0, 0.8)  # some
