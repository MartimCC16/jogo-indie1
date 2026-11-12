# ============================================================================
# caixa_dialogo.gd  —  Caixa de diálogo (AUTOLOAD chamado Dialogo)
# ----------------------------------------------------------------------------
# Mostra falas lidas de arquivos JSON da pasta dialogues/.
#
# COMO USAR em qualquer script:
#     await Dialogo.iniciar("res://dialogues/vila_ancora.json", "tome_inicio")
# O "await" faz o script esperar a conversa inteira acabar antes de continuar.
#
# Controles: tecla de AÇÃO (Z/Espaço/Enter)
#   - enquanto o texto está sendo "digitado": mostra o texto todo de uma vez;
#   - com o texto completo: passa para a próxima fala (ou fecha no final).
#
# Formato dos arquivos: veja o README (seção "Diálogos em JSON").
# ============================================================================
extends CanvasLayer

## Avisa quando uma conversa começa / termina.
signal iniciou
signal terminou

## Arquivo com o nome e a cor de cada personagem que fala.
const ARQUIVO_PERSONAGENS := "res://dialogues/personagens.json"
## Quantas letras aparecem por segundo no efeito de "digitação".
const LETRAS_POR_SEGUNDO := 40.0

## true enquanto a caixa está aberta. O jogador não anda nesse tempo.
var esta_ativo := false

var _falas: Array = []          # lista de falas da conversa atual
var _indice := 0                # qual fala está na tela
var _letras := 0.0              # quantas letras já apareceram (com fração)
var _digitando := false         # o texto ainda está aparecendo?
var _quadro_de_inicio := 0      # para ignorar a tecla no mesmo quadro em que abriu
var _personagens: Dictionary = {}

@onready var painel: PanelContainer = $Painel
@onready var texto: Label = $Painel/Texto
@onready var painel_nome: PanelContainer = $PainelNome
@onready var nome: Label = $PainelNome/Nome
@onready var indicador: ColorRect = $Indicador


func _ready() -> void:
	_personagens = carregar_json(ARQUIVO_PERSONAGENS)
	_esconder_tudo()


## Abre a conversa "id_conversa" do arquivo JSON indicado e espera ela acabar.
func iniciar(arquivo: String, id_conversa: String) -> void:
	var dados := carregar_json(arquivo)
	if not dados.has(id_conversa):
		push_error("Diálogo '%s' não existe em %s" % [id_conversa, arquivo])
		return
	await iniciar_falas(dados[id_conversa])


## Abre uma conversa a partir de uma lista de falas já carregada.
func iniciar_falas(falas: Array) -> void:
	if esta_ativo or falas.is_empty():
		return
	_falas = falas
	_indice = 0
	esta_ativo = true
	_quadro_de_inicio = Engine.get_process_frames()
	painel.show()
	_mostrar_fala_atual()
	iniciou.emit()
	await terminou


func _process(delta: float) -> void:
	if not esta_ativo:
		return
	if _digitando:
		_letras += LETRAS_POR_SEGUNDO * delta
		texto.visible_characters = int(_letras)
		if texto.visible_characters >= texto.get_total_character_count():
			_terminar_digitacao()
	else:
		# Indicador pisca: visível por meio segundo, invisível por meio segundo.
		indicador.visible = fmod(Time.get_ticks_msec() / 500.0, 2.0) < 1.0


func _unhandled_input(event: InputEvent) -> void:
	if not esta_ativo or not event.is_action_pressed("acao"):
		return
	# A tecla é "nossa": ninguém mais recebe este aperto.
	get_viewport().set_input_as_handled()
	# Ignora o mesmo aperto que abriu a conversa.
	if Engine.get_process_frames() == _quadro_de_inicio:
		return
	if _digitando:
		_terminar_digitacao()
	else:
		_indice += 1
		if _indice < _falas.size():
			_mostrar_fala_atual()
		else:
			_fechar()


func _mostrar_fala_atual() -> void:
	var fala: Dictionary = _falas[_indice]
	var quem: String = fala.get("quem", "")
	texto.text = fala.get("texto", "...")

	# Procura o nome bonito e a cor em personagens.json.
	# Se não achar, mostra o que estiver escrito em "quem".
	var info: Dictionary = _personagens.get(quem, {})
	var nome_exibido: String = info.get("nome", quem)
	nome.text = nome_exibido
	nome.add_theme_color_override("font_color", Color.from_string(info.get("cor", "#ffffff"), Color.WHITE))
	painel_nome.visible = nome_exibido != ""
	painel_nome.reset_size()  # ajusta a largura da plaquinha ao tamanho do nome

	# Começa a "digitar" do zero.
	_letras = 0.0
	texto.visible_characters = 0
	_digitando = true
	indicador.hide()


func _terminar_digitacao() -> void:
	_digitando = false
	texto.visible_characters = -1  # -1 = mostrar tudo


func _fechar() -> void:
	_esconder_tudo()
	esta_ativo = false
	terminou.emit()


func _esconder_tudo() -> void:
	painel.hide()
	painel_nome.hide()
	indicador.hide()


## Lê um arquivo JSON (a função de verdade fica em scripts/util/dados.gd).
func carregar_json(caminho: String) -> Dictionary:
	return Dados.carregar_json(caminho)
