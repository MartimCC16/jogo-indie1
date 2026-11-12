# ============================================================================
# vila_ancora.gd  —  Script principal da cena da Vila Âncora
# ----------------------------------------------------------------------------
# Por enquanto ele:
#   - coloca a Lia no marcador "InicioLia";
#   - limita a câmera da Lia às bordas do mapa;
#   - mostra o nome da região na tela e some devagar.
# Nas próximas etapas, aqui vamos ligar o NPC e o evento da praia.
# ============================================================================
extends Node2D

# Texto que aparece quando a cena começa.
@export var nome_da_regiao := "Vila Âncora"

@onready var mapa: MapaDeTexto = $Mapa
@onready var lia: Jogador = $Entidades/Lia
@onready var nome_regiao: Label = $Interface/NomeRegiao
@onready var inicio_lia: Marker2D = $Marcadores/InicioLia


func _ready() -> void:
	# Obs.: o _ready() dos filhos roda ANTES do pai. Então, quando chegamos
	# aqui, o nó "Mapa" já gerou os tiles (se precisava).
	lia.global_position = inicio_lia.global_position
	lia.limitar_camera(mapa.retangulo_em_pixels())
	_mostrar_nome_regiao()


func _mostrar_nome_regiao() -> void:
	nome_regiao.text = nome_da_regiao
	nome_regiao.modulate.a = 0.0  # começa invisível (a = transparência)
	# Um "tween" anima uma propriedade ao longo do tempo, passo a passo:
	var tween := create_tween()
	tween.tween_property(nome_regiao, "modulate:a", 1.0, 0.6)  # aparece
	tween.tween_interval(2.0)                                   # espera
	tween.tween_property(nome_regiao, "modulate:a", 0.0, 0.8)  # some
