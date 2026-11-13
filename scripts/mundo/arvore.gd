# ============================================================================
# arvore.gd  —  Árvore grande do cenário (3 x 5 tiles), com 4 estações
# ----------------------------------------------------------------------------
# A imagem fica em assets/sprites/cenario/arvore_grande.png:
#   4 quadros de 48x80 -> 0 primavera | 1 verão | 2 outono | 3 inverno
#
# Só o TRONCO tem colisão: a Lia pode passar POR TRÁS da copa. Para isso
# funcionar, a árvore precisa estar dentro de um nó com "Y Sort Enabled"
# (na vila: Entidades/Arvores). O Y-Sort desenha na frente quem está mais
# embaixo na tela.
#
# O "@tool" faz a troca de estação aparecer na hora, dentro do editor.
# ============================================================================
@tool
class_name Arvore
extends StaticBody2D

# Na vila os 4 quadros são as estações; em outras regiões são só variações.
enum Estacao { PRIMAVERA, VERAO, OUTONO, INVERNO }

## Qual quadro da imagem usar.
@export var estacao: Estacao = Estacao.VERAO:
	set(nova):
		estacao = nova
		_atualizar_visual()

## Outra imagem (outra região). Vazio = a imagem padrão da cena.
@export var textura: Texture2D:
	set(nova):
		textura = nova
		_atualizar_visual()

## Espelha a árvore (para as árvores não parecerem todas iguais).
@export var espelhar := false:
	set(novo):
		espelhar = novo
		_atualizar_visual()


func _ready() -> void:
	_atualizar_visual()


func _atualizar_visual() -> void:
	var sprite := get_node_or_null("Sprite") as Sprite2D
	if sprite:
		if textura:
			sprite.texture = textura
		sprite.frame = estacao
		sprite.flip_h = espelhar
