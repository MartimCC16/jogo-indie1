# ============================================================================
# jogador.gd  —  Personagem controlado pelo jogador (andar em 4 direções)
# ----------------------------------------------------------------------------
# Usado pela cena scenes/personagens/lia.tscn, mas é genérico: se no futuro
# outro aliado puder ser controlado no mapa, ele reaproveita este script.
#
# A cena precisa ter estes filhos:
#   - Sprite2D "Sprite"      : folha 32x64 (2 colunas = passos, 4 linhas = direções)
#   - CollisionShape2D       : a "caixa" que bate nas paredes (só nos pés)
#   - Camera2D "Camera"      : a câmera que segue o personagem
# ============================================================================
class_name Jogador
extends CharacterBody2D

# Linhas da folha de sprites (iguais às do README).
enum Direcao { BAIXO = 0, CIMA = 1, ESQUERDA = 2, DIREITA = 3 }

## Velocidade de caminhada em pixels por segundo (16 px = 1 tile).
@export var velocidade := 70.0
## Tempo (segundos) entre os dois quadros da animação de passo.
@export var tempo_por_passo := 0.15

## Quando for "false", o jogador não anda (ex.: durante diálogos e cenas).
var pode_mover := true
## Para onde o personagem está olhando. Útil para conversar com NPCs depois.
var direcao_olhar: Direcao = Direcao.BAIXO

var _cronometro_passo := 0.0
var _quadro_passo := 0

@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera


# _physics_process roda em passos fixos (60x por segundo), ideal para movimento.
func _physics_process(delta: float) -> void:
	var entrada := Vector2.ZERO
	if pode_mover:
		# Junta as 4 teclas num vetor. Na diagonal ele já vem "normalizado"
		# (tamanho 1), então andar na diagonal não fica mais rápido.
		entrada = Input.get_vector("mover_esquerda", "mover_direita", "mover_cima", "mover_baixo")

	velocity = entrada * velocidade
	# move_and_slide() move o corpo e "desliza" ao bater numa parede,
	# em vez de parar seco. Ele usa a variável "velocity" acima.
	move_and_slide()

	_atualizar_animacao(entrada, delta)


func _atualizar_animacao(entrada: Vector2, delta: float) -> void:
	if entrada != Vector2.ZERO:
		# Escolhe a direção pelo eixo mais forte (horizontal ou vertical).
		if abs(entrada.x) > abs(entrada.y):
			direcao_olhar = Direcao.DIREITA if entrada.x > 0 else Direcao.ESQUERDA
		else:
			direcao_olhar = Direcao.BAIXO if entrada.y > 0 else Direcao.CIMA

		# Alterna o quadro do passo de tempos em tempos.
		_cronometro_passo += delta
		if _cronometro_passo >= tempo_por_passo:
			_cronometro_passo = 0.0
			_quadro_passo = 1 - _quadro_passo
	else:
		# Parado: volta para o primeiro quadro.
		_cronometro_passo = 0.0
		_quadro_passo = 0

	sprite.frame_coords = Vector2i(_quadro_passo, direcao_olhar)


## Vetor da direção para onde o personagem olha, ex.: (0, 1) = para baixo.
func vetor_olhar() -> Vector2:
	match direcao_olhar:
		Direcao.CIMA:
			return Vector2.UP
		Direcao.ESQUERDA:
			return Vector2.LEFT
		Direcao.DIREITA:
			return Vector2.RIGHT
	return Vector2.DOWN


## Impede a câmera de mostrar o que está fora do retângulo (em pixels).
func limitar_camera(retangulo: Rect2) -> void:
	camera.limit_left = int(retangulo.position.x)
	camera.limit_top = int(retangulo.position.y)
	camera.limit_right = int(retangulo.end.x)
	camera.limit_bottom = int(retangulo.end.y)
	# Faz a câmera "pular" direto para o lugar certo, sem deslizar no início.
	camera.reset_smoothing()
