# ============================================================================
# estado_jogo.gd  —  "Memória" do jogo (AUTOLOAD chamado EstadoJogo)
# ----------------------------------------------------------------------------
# Um AUTOLOAD é um nó que o Godot cria sozinho quando o jogo abre e que fica
# vivo o tempo todo, mesmo trocando de cena. Qualquer script pode usá-lo
# escrevendo o nome dele, ex.: EstadoJogo.marcar_flag("abriu_bau").
# (Registrado em Projeto > Configurações do Projeto > aba Globais/Autoload.)
#
# "Flags" (bandeiras) são marcações de coisas que já aconteceram na história:
#   "conversou_tome", "eco_despertou", "lobo_derrotado"...
# Mais tarde, o sistema de salvar o jogo vai gravar este dicionário.
# ============================================================================
extends Node

var flags: Dictionary = {}


## Marca que algo aconteceu.
func marcar_flag(nome: String) -> void:
	flags[nome] = true


## Pergunta se algo já aconteceu.
func tem_flag(nome: String) -> bool:
	return flags.get(nome, false)


# ---------------------------------------------------------------------------
# TROCA DE CENA COM ESCURECIMENTO (fade)
# ---------------------------------------------------------------------------

## Onde o jogador deve aparecer ao voltar para um mapa (null = no início).
var posicao_retorno = null
## Nome do marcador de entrada onde a Lia aparece no próximo mapa.
var entrada_alvo := ""
## Para onde a Lia olha ao chegar (-1 = não muda).
var direcao_entrada := -1


## Vai para outro mapa, aparecendo no marcador "entrada" (Marcadores/<entrada>).
func ir_para_mapa(cena: String, entrada: String, direcao := -1) -> void:
	entrada_alvo = entrada
	direcao_entrada = direcao
	posicao_retorno = null
	trocar_cena(cena)

var _cortina: ColorRect      # retângulo preto que cobre a tela
var _trocando := false


func _ready() -> void:
	# Cria a "cortina" preta uma vez só. Como este nó é um autoload, ela
	# continua existindo mesmo quando a cena muda.
	var camada := CanvasLayer.new()
	camada.layer = 50  # por cima de tudo
	_cortina = ColorRect.new()
	_cortina.color = Color(0, 0, 0, 0)
	_cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cortina.set_anchors_preset(Control.PRESET_FULL_RECT)
	camada.add_child(_cortina)
	add_child(camada)


## Escurece a tela, troca de cena e clareia de novo.
func trocar_cena(caminho: String) -> void:
	if _trocando:
		return
	_trocando = true
	var tween := create_tween()
	tween.tween_property(_cortina, "color:a", 1.0, 0.4)
	await tween.finished
	get_tree().change_scene_to_file(caminho)
	# A troca acontece no próximo quadro; esperamos a cena nova aparecer.
	await get_tree().process_frame
	await get_tree().process_frame
	tween = create_tween()
	tween.tween_property(_cortina, "color:a", 0.0, 0.4)
	await tween.finished
	_trocando = false


# ---------------------------------------------------------------------------
# BATALHAS
# ---------------------------------------------------------------------------

## Configuração da próxima batalha (quem luta e para onde voltar).
var proxima_batalha: Dictionary = {}
## true se a última batalha terminou em vitória.
var venceu_ultima_batalha := false

const CENA_BATALHA := "res://scenes/combate/batalha.tscn"


## Troca para a tela de batalha.
##   inimigos: lista de ids de data/inimigos.json, ex.: ["lobo_nevoa"]
##   cena_retorno: cena para onde voltar no final (ex.: o mapa atual)
##   tutorial: true para mostrar as dicas de tutorial (dialogues/tutorial.json)
##   flag_vitoria: flag marcada se o jogador vencer (ex.: "derrotou_fiapo_1")
func iniciar_batalha(inimigos: Array, cena_retorno := "", tutorial := false, flag_vitoria := "") -> void:
	repetir_batalha({"inimigos": inimigos, "cena_retorno": cena_retorno,
		"tutorial": tutorial, "flag_vitoria": flag_vitoria})


## Começa uma batalha com uma configuração pronta (usado para "tentar de novo").
func repetir_batalha(config: Dictionary) -> void:
	proxima_batalha = config
	trocar_cena(CENA_BATALHA)


## Chamado pela batalha quando ela termina com vitória.
func registrar_fim_batalha(venceu: bool) -> void:
	venceu_ultima_batalha = venceu
	var flag: String = proxima_batalha.get("flag_vitoria", "")
	if venceu and flag != "":
		marcar_flag(flag)
	proxima_batalha = {}
