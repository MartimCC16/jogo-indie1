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
