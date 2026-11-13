# ============================================================================
# vila_ancora.gd  —  Script principal da cena da Vila Âncora
# ----------------------------------------------------------------------------
# Por enquanto ele:
#   - coloca a Lia no marcador "InicioLia";
#   - limita a câmera da Lia às bordas do mapa;
#   - mostra o nome da região na tela e some devagar.
#   - se Sir Eco já despertou, faz ele seguir a Lia;
#   - ao voltar da batalha contra o Lobo da Névoa, mostra o FINAL DO PRÓLOGO.
# ============================================================================
extends Node2D

# Texto que aparece quando a cena começa.
@export var nome_da_regiao := "Vila Âncora"

@onready var mapa: MapaDeTexto = $Mapa
@onready var lia: Jogador = $Entidades/Lia
@onready var nome_regiao: Label = $Interface/NomeRegiao
@onready var inicio_lia: Marker2D = $Marcadores/InicioLia
@onready var sir_eco: Seguidor = $Entidades/SirEco


func _ready() -> void:
	# Obs.: o _ready() dos filhos roda ANTES do pai. Então, quando chegamos
	# aqui, o nó "Mapa" já gerou os tiles (se precisava).
	# Voltando de uma batalha? Então a Lia aparece onde estava.
	if EstadoJogo.posicao_retorno != null:
		lia.global_position = EstadoJogo.posicao_retorno
		EstadoJogo.posicao_retorno = null
	else:
		lia.global_position = inicio_lia.global_position
	lia.limitar_camera(mapa.retangulo_em_pixels())
	_preparar_sir_eco()

	if _deve_mostrar_final_do_prologo():
		_cena_final_do_prologo()
	else:
		_mostrar_nome_regiao()


## Se o Sir Eco já despertou (ex.: voltando para a vila depois), ele já
## aparece seguindo a Lia e a armadura caída some do mapa.
func _preparar_sir_eco() -> void:
	if not EstadoJogo.tem_flag("eco_despertou"):
		return
	var armadura := get_node_or_null("Entidades/ArmaduraCaida")
	if armadura:
		armadura.queue_free()
	sir_eco.global_position = lia.global_position + Vector2(14, 0)
	sir_eco.seguir(lia)


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


func _mostrar_nome_regiao() -> void:
	nome_regiao.text = nome_da_regiao
	nome_regiao.modulate.a = 0.0  # começa invisível (a = transparência)
	# Um "tween" anima uma propriedade ao longo do tempo, passo a passo:
	var tween := create_tween()
	tween.tween_property(nome_regiao, "modulate:a", 1.0, 0.6)  # aparece
	tween.tween_interval(2.0)                                   # espera
	tween.tween_property(nome_regiao, "modulate:a", 0.0, 0.8)  # some
