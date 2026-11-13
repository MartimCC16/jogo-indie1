# ============================================================================
# barra.gd  —  Barra simples de vida/mana desenhada por código
# ----------------------------------------------------------------------------
# "valor" vai de 0.0 (vazia) a 1.0 (cheia). Use definir(0.5) para animar até
# a metade. O tamanho é o "custom_minimum_size" (ex.: 70 x 5 pixels).
# ============================================================================
class_name Barra
extends Control

@export var cor := Color("#e04848"):
	set(novo):
		cor = novo
		queue_redraw()  # pede para o Godot redesenhar a barra

@export var cor_fundo := Color(0.42, 0.24, 0.12)

@export_range(0.0, 1.0) var valor := 1.0:
	set(novo):
		valor = clampf(novo, 0.0, 1.0)
		queue_redraw()


## Muda o valor; se "animar" for true, a barra desliza até lá.
func definir(novo_valor: float, animar := true) -> void:
	if animar and is_inside_tree():
		create_tween().tween_property(self, "valor", novo_valor, 0.35)
	else:
		valor = novo_valor


# _draw é chamado pelo Godot quando a barra precisa ser desenhada.
func _draw() -> void:
	var tamanho := size
	draw_rect(Rect2(Vector2.ZERO, tamanho), Color(0.25, 0.12, 0.05))  # borda marrom-escura
	var interno := Rect2(Vector2.ONE, tamanho - Vector2(2, 2))
	draw_rect(interno, cor_fundo)                                      # fundo
	interno.size.x = floorf(interno.size.x * valor)
	draw_rect(interno, cor)                                            # parte cheia
