# ============================================================================
# vila_ancora.gd  —  Script principal da cena da Vila Âncora
# ----------------------------------------------------------------------------
# Por enquanto ele:
#   - coloca a Lia no marcador "InicioLia";
#   - limita a câmera da Lia às bordas do mapa;
#   - mostra o nome da região na tela e some devagar.
#   - se Sir Eco já despertou, faz ele seguir a Lia.
# ============================================================================
extends Node2D

# Texto que aparece quando a cena começa.
@export var nome_da_regiao := "Vila Âncora"

@onready var mapa: MapaDeTexto = $Mapa
@onready var lia: Jogador = $Entidades/Lia
@onready var nome_regiao: Label = $Interface/NomeRegiao
@onready var inicio_lia: Marker2D = $Marcadores/InicioLia
@onready var sir_eco: Seguidor = $Entidades/SirEco


func _ready() -> void:
	# Obs.: o _ready() dos filhos roda ANTES do pai. Então, quando chegamos
	# aqui, o nó "Mapa" já gerou os tiles (se precisava).
	lia.global_position = inicio_lia.global_position
	lia.limitar_camera(mapa.retangulo_em_pixels())
	_preparar_sir_eco()
	_mostrar_nome_regiao()


## Se o Sir Eco já despertou (ex.: voltando para a vila depois), ele já
## aparece seguindo a Lia e a armadura caída some do mapa.
func _preparar_sir_eco() -> void:
	if not EstadoJogo.tem_flag("eco_despertou"):
		return
	var armadura := get_node_or_null("Entidades/ArmaduraCaida")
	if armadura:
		armadura.queue_free()
	sir_eco.global_position = lia.global_position
	sir_eco.seguir(lia)


func _mostrar_nome_regiao() -> void:
	nome_regiao.text = nome_da_regiao
	nome_regiao.modulate.a = 0.0  # começa invisível (a = transparência)
	# Um "tween" anima uma propriedade ao longo do tempo, passo a passo:
	var tween := create_tween()
	tween.tween_property(nome_regiao, "modulate:a", 1.0, 0.6)  # aparece
	tween.tween_interval(2.0)                                   # espera
	tween.tween_property(nome_regiao, "modulate:a", 0.0, 0.8)  # some
