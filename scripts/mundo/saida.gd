# ============================================================================
# saida.gd  —  Área invisível que leva a Lia para OUTRO MAPA
# ----------------------------------------------------------------------------
# Como usar (no editor):
#   1. Arraste scenes/mundo/saida.tscn para dentro do nó "Saidas" do mapa.
#   2. Posicione na borda do mapa e ajuste o campo "Tamanho" no Inspetor.
#   3. No Inspetor: escolha a "Cena Destino" e o nome da "Entrada Destino"
#      (um Marker2D dentro de "Marcadores" no outro mapa).
#
# Saída trancada: preencha "Flag Necessaria". Enquanto a flag não existir,
# a Lia ouve o diálogo "Dialogo Bloqueado" e dá um passo para trás.
# ============================================================================
class_name Saida
extends Area2D

## Mapa para onde esta saída leva.
@export_file("*.tscn") var cena_destino := ""
## Nome do marcador de entrada no outro mapa (ex.: "sul").
@export var entrada_destino := ""
## Para onde a Lia olha ao chegar.
@export var olhar_ao_chegar: Jogador.Direcao = Jogador.Direcao.BAIXO
## Tamanho da área (em pixels). Para ver no jogo: Depurar > Formas de Colisão Visíveis.
@export var tamanho := Vector2(48, 8)

@export_group("Saída trancada")
## Só deixa passar se esta flag existir (vazio = sempre aberta).
@export var flag_necessaria := ""
@export_file("*.json") var arquivo_dialogo := ""
## Conversa mostrada quando a saída está trancada.
@export var dialogo_bloqueado := ""

var _usada := false


func _ready() -> void:
	# Cada saída ganha a sua própria forma, com o tamanho escolhido.
	var forma := RectangleShape2D.new()
	forma.size = tamanho
	$Forma.shape = forma
	# "body_entered" é um SINAL: avisa quando um corpo entra na área.
	body_entered.connect(_ao_entrar_corpo)


func _ao_entrar_corpo(corpo: Node2D) -> void:
	if _usada or not corpo is Jogador:
		return
	var lia := corpo as Jogador

	if flag_necessaria != "" and not EstadoJogo.tem_flag(flag_necessaria):
		lia.pode_mover = false
		if dialogo_bloqueado != "" and arquivo_dialogo != "":
			await Dialogo.iniciar(arquivo_dialogo, dialogo_bloqueado)
		# Dá um passo para trás, para sair de cima da saída.
		lia.global_position -= lia.vetor_olhar() * 12.0
		lia.pode_mover = true
		return

	if cena_destino == "":
		push_warning("Saída sem 'Cena Destino': " + str(get_path()))
		return
	_usada = true
	lia.pode_mover = false
	EstadoJogo.ir_para_mapa(cena_destino, entrada_destino, olhar_ao_chegar)
