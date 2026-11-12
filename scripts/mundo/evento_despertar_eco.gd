# ============================================================================
# evento_despertar_eco.gd  —  EVENTO DA PRAIA: a armadura caída desperta
# ----------------------------------------------------------------------------
# A armadura fica deitada na areia. Quando a Lia examina (tecla de AÇÃO),
# acontece a "cena" (cutscene):
#   1. Lia examina a armadura (diálogo "praia_examinar");
#   2. a lanterna brilha, a tela pisca e a armadura treme;
#   3. a armadura some e Sir Eco aparece de pé;
#   4. os dois conversam (diálogo "praia_despertar");
#   5. a flag "eco_despertou" é marcada;
#   6. o LOBO DA NÉVOA surge da névoa (diálogo "lobo_aparece");
#   7. começa a batalha contra o chefe, com tutorial. Ao vencer, o jogo volta
#      para a vila, e o vila_ancora.gd mostra o final do prólogo.
#
# As falas estão em dialogues/praia.json. Para mudar a ORDEM das coisas,
# mexa na função _executar_cena() abaixo: ela lê de cima para baixo como
# um roteiro, e cada "await" significa "espere isto terminar".
# ============================================================================
extends StaticBody2D

## Nome da flag marcada quando o evento termina.
const FLAG := "eco_despertou"
const ARQUIVO_DIALOGOS := "res://dialogues/praia.json"
const TEXTURA_LOBO := preload("res://assets/sprites/inimigos/lobo_nevoa.png")

## O nó do Sir Eco (seguidor) que vai aparecer de pé. Escolha no Inspetor.
@export var sir_eco: Seguidor

var _em_andamento := false

@onready var sprite: Sprite2D = $Sprite


## Chamado pela Lia quando ela aperta AÇÃO perto da armadura.
func interagir(jogador: Node2D) -> void:
	if _em_andamento:
		return
	_em_andamento = true
	await _executar_cena(jogador as Jogador)


# ---------------------------------------------------------------------------
# O ROTEIRO da cena.
# ---------------------------------------------------------------------------
func _executar_cena(lia: Jogador) -> void:
	lia.pode_mover = false
	lia.olhar_para(global_position)

	await Dialogo.iniciar(ARQUIVO_DIALOGOS, "praia_examinar")

	# A armadura treme...
	await _tremer(0.8)
	# ...a tela pisca com a luz da lanterna...
	await _piscar_tela()
	# ...e no lugar da armadura caída, aparece Sir Eco de pé.
	sprite.hide()
	$Colisao.set_deferred("disabled", true)
	sir_eco.global_position = global_position
	sir_eco.show()
	sir_eco.olhar_para(lia.global_position)
	await _pulinho(sir_eco)
	await espera(0.4)

	await Dialogo.iniciar(ARQUIVO_DIALOGOS, "praia_despertar")

	EstadoJogo.marcar_flag(FLAG)

	# O uivo... e o Lobo da Névoa aparece!
	await _lobo_aparece(lia)

	# Começa a batalha contra o chefe (com tutorial).
	# Ao voltar, a Lia reaparece neste mesmo lugar da praia.
	EstadoJogo.marcar_flag("luta_lobo_iniciada")
	EstadoJogo.posicao_retorno = lia.global_position
	EstadoJogo.iniciar_batalha(["lobo_nevoa"], get_tree().current_scene.scene_file_path, true)


# ---------------------------------------------------------------------------
# Efeitos usados no roteiro (dá para reaproveitar em outros eventos).
# ---------------------------------------------------------------------------

## O lobo surge à esquerda, saindo da névoa (aparece aos poucos).
func _lobo_aparece(lia: Jogador) -> void:
	var lobo := Sprite2D.new()
	lobo.texture = TEXTURA_LOBO
	lobo.flip_h = true  # olhando para a direita, na direção da Lia
	lobo.modulate.a = 0.0
	get_parent().add_child(lobo)
	lobo.global_position = global_position + Vector2(-90, -8)

	var tween := create_tween()
	tween.tween_property(lobo, "modulate:a", 1.0, 1.0)
	tween.parallel().tween_property(lobo, "global_position", global_position + Vector2(-56, -8), 1.0)
	await tween.finished

	lia.olhar_para(lobo.global_position)
	sir_eco.olhar_para(lobo.global_position)
	await Dialogo.iniciar(ARQUIVO_DIALOGOS, "lobo_aparece")


## Espera alguns segundos.
func espera(segundos: float) -> void:
	await get_tree().create_timer(segundos).timeout


## Faz o sprite tremer para os lados durante "duracao" segundos.
func _tremer(duracao: float) -> void:
	var tween := create_tween()
	var vezes := int(duracao / 0.1)
	for i in vezes:
		tween.tween_property(sprite, "position:x", 1.0, 0.05)
		tween.tween_property(sprite, "position:x", -1.0, 0.05)
	tween.tween_property(sprite, "position:x", 0.0, 0.05)
	await tween.finished


## Pisca a tela inteira com uma luz amarelada (a Lanterna de Luz).
func _piscar_tela() -> void:
	# Cria na hora uma camada por cima de tudo com um retângulo colorido.
	var camada := CanvasLayer.new()
	camada.layer = 5
	var luz := ColorRect.new()
	luz.color = Color(1.0, 0.95, 0.7, 0.0)  # começa transparente
	luz.set_anchors_preset(Control.PRESET_FULL_RECT)
	camada.add_child(luz)
	get_tree().current_scene.add_child(camada)

	var tween := create_tween()
	tween.tween_property(luz, "color:a", 0.9, 0.15)  # acende
	tween.tween_interval(0.2)
	tween.tween_property(luz, "color:a", 0.0, 0.7)   # apaga devagar
	await tween.finished
	camada.queue_free()


## Um pulinho para cima e para baixo (o Eco "se levantando").
func _pulinho(alvo: Node2D) -> void:
	var y_original := alvo.position.y
	var tween := create_tween()
	tween.tween_property(alvo, "position:y", y_original - 6.0, 0.15)
	tween.tween_property(alvo, "position:y", y_original, 0.15)
	await tween.finished
