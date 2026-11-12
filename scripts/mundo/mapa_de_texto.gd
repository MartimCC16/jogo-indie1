# ============================================================================
# mapa_de_texto.gd  —  Monta um mapa de tiles a partir de um arquivo de TEXTO
# ----------------------------------------------------------------------------
# Em vez de pintar tile por tile, você desenha o mapa com letras num arquivo
# .txt (ex.: data/mapas/vila_ancora.txt), e este script coloca os tiles certos.
#
# Este nó precisa ter DOIS filhos do tipo TileMapLayer:
#   - "Chao"    : grama, areia, água, caminho... (camada de baixo)
#   - "Objetos" : casas, árvores, rochas, cercas  (camada de cima)
#
# Como usar no editor:
#   1. Selecione o nó que tem este script (na cena da vila, é o nó "Mapa").
#   2. No Inspetor, clique em "Gerar mapa a partir do texto".
#   3. Salve a cena (Ctrl+S). Pronto: os tiles ficam gravados na cena e você
#      ainda pode retocar à mão com o pincel de TileMap se quiser.
#
# Se a cena for rodada com as camadas VAZIAS, o mapa é gerado sozinho.
#
# O "@tool" na linha abaixo faz este script rodar TAMBÉM dentro do editor
# (é isso que permite o botão no Inspetor funcionar). Requer Godot 4.4+.
# ============================================================================
@tool
class_name MapaDeTexto
extends Node2D

## Arquivo .txt com o desenho do mapa (uma letra por tile).
@export_file("*.txt") var arquivo_mapa: String = ""

## Botões que aparecem no Inspetor do editor.
@export_tool_button("Gerar mapa a partir do texto", "TileMapLayer") var _botao_gerar = gerar_mapa
@export_tool_button("Limpar mapa", "Remove") var _botao_limpar = limpar_mapa

# ID da fonte de tiles dentro do TileSet (só temos uma imagem: id 0).
const FONTE := 0

# Posições dos tiles dentro de tileset_vila.png (coluna, linha).
const GRAMA := Vector2i(0, 0)
const GRAMA_FLOR := Vector2i(1, 0)
const CAMINHO := Vector2i(2, 0)
const AREIA := Vector2i(3, 0)
const AGUA := Vector2i(4, 0)
const ESPUMA := Vector2i(5, 0)
const ROCHA := Vector2i(6, 0)
const ARVORE := Vector2i(7, 0)
const PAREDE := Vector2i(0, 1)
const TELHADO := Vector2i(1, 1)
const PORTA := Vector2i(2, 1)
const JANELA := Vector2i(3, 1)
const CERCA := Vector2i(4, 1)
const PISO := Vector2i(5, 1)

# LEGENDA: cada letra do arquivo vira um tile no "chao" e, se tiver,
# um tile na camada de "objeto" por cima.
# Para criar uma letra nova, é só acrescentar uma linha aqui.
const LEGENDA := {
	".": {"chao": GRAMA},
	",": {"chao": GRAMA_FLOR},
	"=": {"chao": CAMINHO},
	"s": {"chao": AREIA},
	"~": {"chao": AGUA},
	"-": {"chao": ESPUMA},
	"_": {"chao": PISO},
	"R": {"chao": GRAMA, "objeto": ROCHA},
	"T": {"chao": GRAMA, "objeto": ARVORE},
	"F": {"chao": GRAMA, "objeto": CERCA},
	"^": {"chao": GRAMA, "objeto": TELHADO},
	"#": {"chao": GRAMA, "objeto": PAREDE},
	"J": {"chao": GRAMA, "objeto": JANELA},
	"D": {"chao": GRAMA, "objeto": PORTA},
}


func _ready() -> void:
	# Dentro do editor não fazemos nada automático (só pelo botão).
	if Engine.is_editor_hint():
		return
	# No jogo: se ninguém gerou/pintou o mapa ainda, gera agora.
	if _camada_chao().get_used_cells().is_empty():
		gerar_mapa()


## Lê o arquivo de texto e coloca os tiles nas duas camadas.
func gerar_mapa() -> void:
	var linhas := _ler_linhas_do_arquivo()
	if linhas.is_empty():
		return

	var chao := _camada_chao()
	var objetos := _camada_objetos()
	chao.clear()
	objetos.clear()

	# y = número da linha, x = número da coluna (começando do zero).
	for y in linhas.size():
		var linha: String = linhas[y]
		for x in linha.length():
			var letra := linha[x]
			if not LEGENDA.has(letra):
				push_warning("Letra desconhecida '%s' na linha %d, coluna %d" % [letra, y + 1, x + 1])
				continue
			var regra: Dictionary = LEGENDA[letra]
			var celula := Vector2i(x, y)
			chao.set_cell(celula, FONTE, regra["chao"])
			if regra.has("objeto"):
				objetos.set_cell(celula, FONTE, regra["objeto"])

	print("Mapa gerado: %d linhas de '%s'" % [linhas.size(), arquivo_mapa])


## Apaga todos os tiles das duas camadas.
func limpar_mapa() -> void:
	_camada_chao().clear()
	_camada_objetos().clear()


## Retângulo ocupado pelo mapa, em PIXELS. Útil para limitar a câmera.
func retangulo_em_pixels() -> Rect2:
	var chao := _camada_chao()
	var usado := chao.get_used_rect()  # em células (tiles)
	var tamanho_tile := Vector2(chao.tile_set.tile_size)
	return Rect2(Vector2(usado.position) * tamanho_tile, Vector2(usado.size) * tamanho_tile)


# ---------------------------------------------------------------------------
# Funções auxiliares (o "_" no começo do nome indica que são de uso interno).
# ---------------------------------------------------------------------------

func _camada_chao() -> TileMapLayer:
	return get_node("Chao") as TileMapLayer


func _camada_objetos() -> TileMapLayer:
	return get_node("Objetos") as TileMapLayer


## Devolve só as linhas do desenho (sem comentários ";" e sem linhas vazias).
func _ler_linhas_do_arquivo() -> Array[String]:
	var resultado: Array[String] = []
	if arquivo_mapa.is_empty():
		push_error("MapaDeTexto: escolha um arquivo .txt em 'Arquivo Mapa' no Inspetor.")
		return resultado
	if not FileAccess.file_exists(arquivo_mapa):
		push_error("MapaDeTexto: arquivo não encontrado: " + arquivo_mapa)
		return resultado

	var texto := FileAccess.get_file_as_string(arquivo_mapa)
	for linha_bruta: String in texto.split("\n"):
		var linha := linha_bruta.strip_edges()  # tira espaços e "\r" das pontas
		if linha.is_empty() or linha.begins_with(";"):
			continue
		resultado.append(linha)
	return resultado
