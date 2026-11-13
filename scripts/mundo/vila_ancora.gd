# ============================================================================
# vila_ancora.gd  —  Script da Vila Âncora (o mapa do prólogo)
# ----------------------------------------------------------------------------
# O que todo mapa faz (posicionar a Lia, câmera, Sir Eco, nome da região)
# vem do MapaBase (scripts/mundo/mapa_base.gd). Aqui fica só o que é da vila:
#   - a armadura caída some depois que o Sir Eco desperta;
#   - ao voltar da batalha contra o Lobo da Névoa, mostra o FINAL DO PRÓLOGO.
# ============================================================================
extends MapaBase


func _preparar_sir_eco() -> void:
	super._preparar_sir_eco()  # "super" = faz o que o MapaBase já fazia
	if EstadoJogo.tem_flag("eco_despertou"):
		var armadura := get_node_or_null("Entidades/ArmaduraCaida")
		if armadura:
			armadura.queue_free()


func _ao_entrar() -> void:
	if _deve_mostrar_final_do_prologo():
		_cena_final_do_prologo()
	else:
		mostrar_nome_regiao()


# ---------------------------------------------------------------------------
# FINAL DO PRÓLOGO
# ---------------------------------------------------------------------------

func _deve_mostrar_final_do_prologo() -> bool:
	return EstadoJogo.tem_flag("luta_lobo_iniciada") \
		and EstadoJogo.venceu_ultima_batalha \
		and not EstadoJogo.tem_flag("lobo_derrotado")


func _cena_final_do_prologo() -> void:
	EstadoJogo.marcar_flag("lobo_derrotado")
	lia.pode_mover = false
	await get_tree().create_timer(1.0).timeout
	lia.olhar_para(sir_eco.global_position)
	sir_eco.olhar_para(lia.global_position)
	await Dialogo.iniciar("res://dialogues/praia.json", "pos_lobo")
	await _tela_fim_do_prologo()
	lia.pode_mover = true


## Tela preta com "Fim do Prólogo". Some quando o jogador aperta AÇÃO.
func _tela_fim_do_prologo() -> void:
	var camada := CanvasLayer.new()
	camada.layer = 15
	add_child(camada)

	var fundo := ColorRect.new()
	fundo.color = Color(0.03, 0.03, 0.07)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	camada.add_child(fundo)

	var titulo := Label.new()
	titulo.text = "NÉVOA E AÇO\n\nFim do Prólogo\n\nObrigado por jogar!"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.set_anchors_preset(Control.PRESET_FULL_RECT)
	titulo.add_theme_color_override("font_color", Color(1, 0.9, 0.62))
	fundo.add_child(titulo)

	var dica := Label.new()
	dica.text = "Aperte AÇÃO para continuar explorando"
	dica.add_theme_font_size_override("font_size", 8)
	dica.add_theme_color_override("font_color", Color(0.85, 0.75, 0.6))
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dica.position = Vector2(0, 158)
	dica.size = Vector2(320, 12)
	fundo.add_child(dica)

	# Aparece devagar...
	fundo.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fundo, "modulate:a", 1.0, 1.2)
	await tween.finished

	# ...espera o jogador apertar AÇÃO...
	await get_tree().process_frame
	while not Input.is_action_just_pressed("acao"):
		await get_tree().process_frame

	# ...e some devagar.
	tween = create_tween()
	tween.tween_property(fundo, "modulate:a", 0.0, 1.0)
	await tween.finished
	camada.queue_free()
