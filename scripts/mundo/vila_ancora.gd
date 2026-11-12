# ============================================================================
# vila_ancora.gd  —  Script principal da cena da Vila Âncora
# ----------------------------------------------------------------------------
# Por enquanto ele:
#   - limita a câmera às bordas do mapa (para não mostrar o "vazio" de fora);
#   - posiciona a câmera no ponto onde a Lia vai começar;
#   - mostra o nome da região na tela e some devagar.
# Nas próximas etapas, aqui vamos colocar a Lia, o NPC e o evento da praia.
# ============================================================================
extends Node2D

# Texto que aparece quando a cena começa.
@export var nome_da_regiao := "Vila Âncora"

@onready var mapa: MapaDeTexto = $Mapa
@onready var camera: Camera2D = $CameraTeste
@onready var nome_regiao: Label = $Interface/NomeRegiao
@onready var inicio_lia: Marker2D = $Marcadores/InicioLia


func _ready() -> void:
	# Obs.: o _ready() dos filhos roda ANTES do pai. Então, quando chegamos
	# aqui, o nó "Mapa" já gerou os tiles (se precisava).
	_limitar_camera_ao_mapa()
	camera.position = inicio_lia.position
	_mostrar_nome_regiao()


func _limitar_camera_ao_mapa() -> void:
	var limites := mapa.retangulo_em_pixels()
	camera.limit_left = int(limites.position.x)
	camera.limit_top = int(limites.position.y)
	camera.limit_right = int(limites.end.x)
	camera.limit_bottom = int(limites.end.y)


func _mostrar_nome_regiao() -> void:
	nome_regiao.text = nome_da_regiao
	nome_regiao.modulate.a = 0.0  # começa invisível (a = transparência)
	# Um "tween" anima uma propriedade ao longo do tempo, passo a passo:
	var tween := create_tween()
	tween.tween_property(nome_regiao, "modulate:a", 1.0, 0.6)  # aparece
	tween.tween_interval(2.0)                                   # espera
	tween.tween_property(nome_regiao, "modulate:a", 0.0, 0.8)  # some
