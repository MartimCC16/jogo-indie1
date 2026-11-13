# ============================================================================
# inimigo_mapa.gd  —  Inimigo que flutua no mapa e começa uma batalha ao tocar
# ----------------------------------------------------------------------------
# Arraste scenes/mundo/inimigo_mapa.tscn para dentro de "Entidades" e, no
# Inspetor, preencha:
#   - Id Unico: um nome único no jogo inteiro (ex.: "floresta_fiapo_1").
#     Depois de vencido, ele não aparece mais (flag "derrotou_<id>").
#   - Inimigos: quem aparece na batalha (ids de data/inimigos.json).
#   - Textura: a imagem no mapa.
# ============================================================================
class_name InimigoMapa
extends Area2D

@export var id_unico := ""
@export var inimigos: Array[String] = ["fiapo_nevoa"]
@export var textura: Texture2D

var _tocou := false

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	if id_unico != "" and EstadoJogo.tem_flag("derrotou_" + id_unico):
		queue_free()  # já foi vencido antes
		return
	if textura:
		sprite.texture = textura
	body_entered.connect(_ao_tocar)
	# Fica flutuando para cima e para baixo, para sempre (set_loops).
	var tween := create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -3.0, 0.7)
	tween.tween_property(sprite, "position:y", 0.0, 0.7)


func _ao_tocar(corpo: Node2D) -> void:
	if _tocou or not corpo is Jogador:
		return
	_tocou = true
	(corpo as Jogador).pode_mover = false
	# Ao voltar da batalha, a Lia aparece onde estava.
	EstadoJogo.posicao_retorno = corpo.global_position
	var flag := "derrotou_" + id_unico if id_unico != "" else ""
	EstadoJogo.iniciar_batalha(inimigos, get_tree().current_scene.scene_file_path, false, flag)
