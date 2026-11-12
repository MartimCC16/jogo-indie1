# ============================================================================
# npc.gd  —  Personagem não jogável que conversa com a Lia
# ----------------------------------------------------------------------------
# Usado por scenes/personagens/npc.tscn. Para criar um NPC novo:
#   1. Arraste npc.tscn para dentro do nó "Entidades" de um mapa.
#   2. No Inspetor, escolha a Textura (folha 32x64), o arquivo de diálogos
#      e os IDs das conversas.
# Pronto! Nenhum código novo é necessário.
# ============================================================================
class_name NPC
extends StaticBody2D

## Folha de sprites do NPC (mesmo formato da Lia: 2 colunas x 4 linhas).
@export var textura: Texture2D
## Identificador único (usado para lembrar se a Lia já falou com ele).
@export var id_npc := "npc"
## Arquivo JSON com as conversas.
@export_file("*.json") var arquivo_dialogos := "res://dialogues/vila_ancora.json"
## Conversa da primeira vez.
@export var dialogo_inicial := ""
## Conversa das outras vezes (se ficar vazio, repete a inicial).
@export var dialogo_repetido := ""
## Para onde ele olha quando ninguém está conversando (0 baixo, 1 cima, 2 esq., 3 dir.).
@export_range(0, 3) var direcao_padrao := 0

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	if textura:
		sprite.texture = textura
	_virar(direcao_padrao)


## Chamado pela Lia quando ela aperta AÇÃO olhando para este NPC.
func interagir(jogador: Node2D) -> void:
	_olhar_para(jogador.global_position)

	var flag := "conversou_" + id_npc
	var conversa := dialogo_inicial
	if dialogo_repetido != "" and EstadoJogo.tem_flag(flag):
		conversa = dialogo_repetido

	await Dialogo.iniciar(arquivo_dialogos, conversa)

	EstadoJogo.marcar_flag(flag)
	_virar(direcao_padrao)


func _olhar_para(ponto: Vector2) -> void:
	var dif := ponto - global_position
	if abs(dif.x) > abs(dif.y):
		_virar(3 if dif.x > 0 else 2)
	else:
		_virar(0 if dif.y > 0 else 1)


func _virar(direcao: int) -> void:
	sprite.frame_coords = Vector2i(0, direcao)
