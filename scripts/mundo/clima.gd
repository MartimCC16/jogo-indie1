# ============================================================================
# clima.gd  —  Ambiente de cada região: cor, NÉVOA e partículas
# ----------------------------------------------------------------------------
# Arraste scenes/mundo/clima.tscn para dentro do mapa e ajuste no Inspetor:
#   - Cor Ambiente: "tinge" o mapa inteiro (branco = sem mudança).
#   - Nevoa Ativa: liga a Névoa do Esquecimento, que se abre em volta da Lia.
#   - Flag Que Dissipa Nevoa: quando esta flag existir (ex.: torre acesa),
#     a névoa não aparece mais e as cores ficam vivas.
#   - Particulas: vagalumes, folhas, neve, brasas ou chuva.
# ============================================================================
class_name Clima
extends Node

enum Particulas { NENHUMA, VAGALUMES, FOLHAS, NEVE, BRASAS, CHUVA }

@export var cor_ambiente := Color.WHITE
@export var particulas: Particulas = Particulas.NENHUMA

@export_group("Névoa")
@export var nevoa_ativa := false
@export var cor_nevoa := Color(0.84, 0.8, 0.94, 0.8)
## Raio (em pixels) do círculo de luz da Lanterna.
@export var raio_da_lanterna := 44.0
@export var suavidade_da_borda := 28.0
@export var flag_que_dissipa_nevoa := ""
## Cor do ambiente DEPOIS que a névoa se dissipa.
@export var cor_ambiente_sem_nevoa := Color.WHITE

@onready var ambiente: CanvasModulate = $Ambiente
@onready var nevoa: ColorRect = $Camada/Nevoa
@onready var emissor: CPUParticles2D = $Camada/Particulas

var _material: ShaderMaterial
var _jogador: Node2D


func _ready() -> void:
	var dissipada := flag_que_dissipa_nevoa != "" and EstadoJogo.tem_flag(flag_que_dissipa_nevoa)
	ambiente.color = cor_ambiente_sem_nevoa if dissipada else cor_ambiente
	nevoa.visible = nevoa_ativa and not dissipada
	_material = nevoa.material as ShaderMaterial
	_material.set_shader_parameter("cor_nevoa", cor_nevoa)
	_material.set_shader_parameter("raio_luz", raio_da_lanterna)
	_material.set_shader_parameter("suavidade", suavidade_da_borda)
	_configurar_particulas()


func _process(_delta: float) -> void:
	if not nevoa.visible:
		return
	if _jogador == null:
		_jogador = get_tree().get_first_node_in_group("jogador") as Node2D
		if _jogador == null:
			return
	# Posição da Lia NA TELA (não no mapa) = centro do círculo de luz.
	var na_tela := _jogador.get_global_transform_with_canvas().origin
	_material.set_shader_parameter("centro_luz", na_tela)
	# Quanto a câmera andou: faz a névoa ficar "presa" ao mundo.
	_material.set_shader_parameter("deslocamento_mundo", -get_viewport().get_canvas_transform().origin)


func _configurar_particulas() -> void:
	emissor.emitting = particulas != Particulas.NENHUMA
	if not emissor.emitting:
		return
	# As partículas nascem espalhadas pela tela inteira (320x180).
	emissor.position = Vector2(160, 90)
	emissor.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	emissor.emission_rect_extents = Vector2(176, 100)
	emissor.direction = Vector2(0, 1)
	emissor.spread = 180.0
	emissor.gravity = Vector2.ZERO
	emissor.preprocess = 5.0  # já começa com partículas na tela
	emissor.scale_amount_min = 1.0
	emissor.scale_amount_max = 2.0
	# Aparecer e sumir suavemente.
	var some := Gradient.new()
	some.set_color(0, Color(1, 1, 1, 0))
	some.set_color(1, Color(1, 1, 1, 0))
	some.add_point(0.2, Color.WHITE)
	some.add_point(0.8, Color.WHITE)
	emissor.color_ramp = some

	match particulas:
		Particulas.VAGALUMES:
			emissor.amount = 26
			emissor.lifetime = 5.0
			emissor.initial_velocity_min = 2.0
			emissor.initial_velocity_max = 7.0
			emissor.color = Color(0.85, 1.0, 0.45)
		Particulas.FOLHAS:
			emissor.amount = 16
			emissor.lifetime = 7.0
			emissor.gravity = Vector2(5, 10)
			emissor.initial_velocity_min = 3.0
			emissor.initial_velocity_max = 8.0
			emissor.color = Color(1.0, 0.62, 0.25)
		Particulas.NEVE:
			emissor.amount = 70
			emissor.lifetime = 6.0
			emissor.gravity = Vector2(4, 16)
			emissor.initial_velocity_min = 1.0
			emissor.initial_velocity_max = 4.0
			emissor.color = Color(1, 1, 1)
		Particulas.BRASAS:
			emissor.amount = 30
			emissor.lifetime = 4.0
			emissor.gravity = Vector2(2, -16)
			emissor.initial_velocity_min = 2.0
			emissor.initial_velocity_max = 6.0
			emissor.color = Color(1.0, 0.55, 0.15)
		Particulas.CHUVA:
			emissor.amount = 140
			emissor.lifetime = 0.8
			emissor.gravity = Vector2(-30, 320)
			emissor.initial_velocity_min = 0.0
			emissor.initial_velocity_max = 0.0
			emissor.scale_amount_max = 1.0
			emissor.color = Color(0.7, 0.85, 1.0, 0.7)
