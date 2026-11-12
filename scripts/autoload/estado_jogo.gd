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
func iniciar_batalha(inimigos: Array, cena_retorno := "") -> void:
	proxima_batalha = {"inimigos": inimigos, "cena_retorno": cena_retorno}
	get_tree().change_scene_to_file(CENA_BATALHA)


## Chamado pela batalha quando ela termina.
func registrar_fim_batalha(venceu: bool) -> void:
	venceu_ultima_batalha = venceu
	proxima_batalha = {}
