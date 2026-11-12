# ============================================================================
# teste_pixel.gd  —  Cena de TESTE da Etapa 1
# ----------------------------------------------------------------------------
# Serve só para conferir se a configuração de pixel art está certa:
#   - os sprites aparecem nítidos (sem borrão), em blocos quadrados;
#   - a janela escala a imagem 320x180 em números inteiros (x4 em 1280x720);
#   - as teclas configuradas (setas/WASD, ação, cancelar) funcionam.
# Depois que o prólogo existir, esta cena pode ser apagada sem problema.
# ============================================================================
extends Node2D

# Tempo (em segundos) entre um quadro de animação e o próximo.
const TEMPO_QUADRO := 0.3

# Lista de ações do "Mapa de Entrada" que queremos testar.
const ACOES := ["mover_cima", "mover_baixo", "mover_esquerda", "mover_direita", "acao", "cancelar"]

# Referências aos nós da cena. O "$" busca um nó filho pelo nome.
# "@onready" significa: só pegue o nó quando a cena estiver pronta.
@onready var lia: Sprite2D = $Lia
@onready var eco: Sprite2D = $SirEco
@onready var aldeao: Sprite2D = $Aldeao
@onready var texto_teclas: Label = $TextoTeclas

var _cronometro := 0.0   # conta o tempo para trocar o quadro da animação
var _coluna := 0         # quadro atual da caminhada (0 ou 1)
var _direcao := 0        # linha da folha de sprites: 0 baixo, 1 cima, 2 esq., 3 dir.


# _process roda uma vez a cada quadro desenhado na tela (~60 vezes por segundo).
# "delta" é quanto tempo passou desde o quadro anterior.
func _process(delta: float) -> void:
	# --- 1) Anima os personagens (troca o quadro de tempos em tempos) ---
	_cronometro += delta
	if _cronometro >= TEMPO_QUADRO:
		_cronometro = 0.0
		_coluna = 1 - _coluna  # alterna entre 0 e 1

	# --- 2) As setas mudam a direção para onde os personagens olham ---
	if Input.is_action_pressed("mover_baixo"):
		_direcao = 0
	elif Input.is_action_pressed("mover_cima"):
		_direcao = 1
	elif Input.is_action_pressed("mover_esquerda"):
		_direcao = 2
	elif Input.is_action_pressed("mover_direita"):
		_direcao = 3

	# frame_coords = Vector2i(coluna, linha) dentro da folha de sprites.
	for sprite in [lia, eco, aldeao]:
		sprite.frame_coords = Vector2i(_coluna, _direcao)

	# --- 3) Mostra na tela quais ações estão apertadas agora ---
	var apertadas: PackedStringArray = []
	for nome_acao in ACOES:
		if Input.is_action_pressed(nome_acao):
			apertadas.append(nome_acao)
	if apertadas.is_empty():
		texto_teclas.text = "Aperte setas/WASD, Z/Espaco/Enter, X/Esc"
	else:
		texto_teclas.text = "Apertando: " + ", ".join(apertadas)
