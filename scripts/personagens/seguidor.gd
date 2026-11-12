# ============================================================================
# seguidor.gd  —  Aliado que anda atrás do jogador (ex.: Sir Eco)
# ----------------------------------------------------------------------------
# Funciona como nos RPGs clássicos: o seguidor guarda o "rastro" de posições
# por onde o líder passou e anda por esse mesmo caminho, alguns passos atrás.
# Ele não tem colisão, para nunca ficar preso numa parede ou trancar a Lia.
#
# A cena precisa de um Sprite2D "Sprite" com folha 32x64 (igual à da Lia).
# Para começar a seguir alguém, chame:  seguidor.seguir(lia)
# ============================================================================
class_name Seguidor
extends Node2D

## Quantos "registros" de posição o seguidor fica atrás do líder.
## Com a Lia a 70 px/s, 14 registros dá mais ou menos 1 tile de distância.
@export var atraso := 14
## Tempo entre os quadros da animação de passo.
@export var tempo_por_passo := 0.15

var lider: Node2D = null       # quem estamos seguindo
var _rastro: Array[Vector2] = []
var _direcao := 0              # 0 baixo, 1 cima, 2 esquerda, 3 direita
var _cronometro := 0.0
var _quadro := 0

@onready var sprite: Sprite2D = $Sprite


## Começa a seguir o "novo_lider".
func seguir(novo_lider: Node2D) -> void:
	lider = novo_lider
	show()
	# Preenche o rastro com uma linha reta de onde estou até o líder,
	# assim eu caminho até ele em vez de "teletransportar".
	_rastro.clear()
	for i in atraso:
		var t := float(i) / atraso
		_rastro.append(global_position.lerp(lider.global_position, t))


## Para de seguir (fica parado onde está).
func parar_de_seguir() -> void:
	lider = null


## Vira o sprite para olhar na direção de um ponto do mapa.
func olhar_para(ponto: Vector2) -> void:
	var dif := ponto - global_position
	if abs(dif.x) > abs(dif.y):
		_direcao = 3 if dif.x > 0 else 2
	else:
		_direcao = 0 if dif.y > 0 else 1
	sprite.frame_coords = Vector2i(0, _direcao)


func _physics_process(delta: float) -> void:
	if lider == null:
		return

	# Só guarda uma posição nova quando o líder realmente se mexeu.
	if _rastro.is_empty() or _rastro.back().distance_to(lider.global_position) > 0.5:
		_rastro.append(lider.global_position)

	var andou := false
	if _rastro.size() > atraso:
		var destino: Vector2 = _rastro.pop_front()
		var dif := destino - global_position
		if dif.length() > 0.01:
			andou = true
			if abs(dif.x) > abs(dif.y):
				_direcao = 3 if dif.x > 0 else 2
			else:
				_direcao = 0 if dif.y > 0 else 1
		global_position = destino

	# Animação de passo (igual à da Lia).
	if andou:
		_cronometro += delta
		if _cronometro >= tempo_por_passo:
			_cronometro = 0.0
			_quadro = 1 - _quadro
	else:
		_quadro = 0
	sprite.frame_coords = Vector2i(_quadro, _direcao)
