# ============================================================================
# camera_teste.gd  —  Câmera PROVISÓRIA que anda com as setas/WASD
# ----------------------------------------------------------------------------
# Só existe para você passear pelo mapa na Etapa 2, antes de a Lia existir.
# Na Etapa 3 ela será removida e a câmera passará a seguir a Lia.
# ============================================================================
extends Camera2D

## Velocidade da câmera em pixels por segundo.
@export var velocidade := 120.0


func _process(delta: float) -> void:
	# get_vector junta as 4 teclas de direção num vetor (x, y).
	# Ex.: segurando direita => (1, 0); direita + baixo => (0.7, 0.7)
	var direcao := Input.get_vector("mover_esquerda", "mover_direita", "mover_cima", "mover_baixo")
	position += direcao * velocidade * delta

	# Não deixa a posição sair muito do mapa (senão a câmera "trava" na borda
	# e demora para voltar). Metade da tela = 160x90 pixels.
	var meia_tela := get_viewport_rect().size / 2.0
	position.x = clamp(position.x, limit_left + meia_tela.x, limit_right - meia_tela.x)
	position.y = clamp(position.y, limit_top + meia_tela.y, limit_bottom - meia_tela.y)
