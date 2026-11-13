# ============================================================================
# barra_timing.gd  —  A mecânica de TIMING do ataque
# ----------------------------------------------------------------------------
# Um cursor branco corre da esquerda para a direita. O jogador aperta AÇÃO:
#   - dentro da faixa DOURADA clara  -> "perfeito" (dano x1.5)
#   - dentro da faixa escura ao redor -> "bom"      (dano x1.0)
#   - fora, ou se não apertar       -> "fraco"    (dano x0.6)
# Uso:  var resultado := await barra_timing.executar()
# ============================================================================
class_name BarraTiming
extends Control

## Quanto tempo (segundos) o cursor leva para atravessar a barra.
@export var duracao := 1.0
## Onde fica o centro da zona perfeita (0.0 = começo, 1.0 = fim).
@export_range(0.0, 1.0) var centro := 0.75
## Metade da largura da zona perfeita e da zona boa (frações da barra).
@export var raio_perfeito := 0.06
@export var raio_bom := 0.16

const COR_FUNDO := Color(0.42, 0.24, 0.12)
const COR_BOM := Color(0.95, 0.62, 0.2)
const COR_PERFEITO := Color(1.0, 0.95, 0.45)

var _progresso := 0.0   # posição do cursor (0.0 a 1.0)


func executar() -> String:
	_progresso = 0.0
	show()
	queue_redraw()
	await get_tree().process_frame
	var resultado := "fraco"
	while true:
		await get_tree().process_frame
		_progresso += get_process_delta_time() / duracao
		queue_redraw()
		if Input.is_action_just_pressed("acao"):
			resultado = _avaliar(_progresso)
			break
		if _progresso >= 1.0:
			break
	# Deixa o cursor parado um instante para o jogador ver onde acertou.
	await get_tree().create_timer(0.25).timeout
	hide()
	return resultado


func _avaliar(posicao: float) -> String:
	var distancia := absf(posicao - centro)
	if distancia <= raio_perfeito:
		return "perfeito"
	if distancia <= raio_bom:
		return "bom"
	return "fraco"


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color(0.25, 0.12, 0.05))
	draw_rect(r.grow(-1), COR_FUNDO)
	var largura := size.x
	draw_rect(Rect2((centro - raio_bom) * largura, 1, raio_bom * 2 * largura, size.y - 2), COR_BOM)
	draw_rect(Rect2((centro - raio_perfeito) * largura, 1, raio_perfeito * 2 * largura, size.y - 2), COR_PERFEITO)
	var x := clampf(_progresso, 0.0, 1.0) * largura
	draw_rect(Rect2(x - 1, -2, 2, size.y + 4), Color.WHITE)
