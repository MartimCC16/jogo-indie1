# ============================================================================
# menu_batalha.gd  —  Menu de opções controlado pelo teclado
# ----------------------------------------------------------------------------
# Uso:  var i := await menu.escolher(["Atacar", "Magia", "Defender"])
#   - setas/WASD para cima e para baixo escolhem;
#   - AÇÃO confirma e devolve o número da opção (0, 1, 2...);
#   - CANCELAR devolve -1 (usado para "voltar").
# Opções desabilitadas (ex.: magia sem mana suficiente) aparecem cinza.
# ============================================================================
class_name MenuBatalha
extends VBoxContainer

const COR_DESABILITADA := Color(0.5, 0.5, 0.55)

var _textos: Array = []
var _habilitadas: Array = []
var _labels: Array[Label] = []
var _indice := 0


func escolher(opcoes: Array, habilitadas: Array = []) -> int:
	_montar(opcoes, habilitadas)
	# Espera um quadro para não usar o mesmo aperto de tecla de antes.
	await get_tree().process_frame
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("mover_baixo"):
			_mover(1)
		elif Input.is_action_just_pressed("mover_cima"):
			_mover(-1)
		elif Input.is_action_just_pressed("acao"):
			if _habilitadas[_indice]:
				var escolhido := _indice
				limpar()
				return escolhido
		elif Input.is_action_just_pressed("cancelar"):
			limpar()
			return -1
	return -1


## Remove as opções da tela.
func limpar() -> void:
	for label in _labels:
		label.queue_free()
	_labels.clear()


func _montar(opcoes: Array, habilitadas: Array) -> void:
	limpar()
	_textos = opcoes
	_habilitadas = habilitadas if habilitadas.size() == opcoes.size() else []
	if _habilitadas.is_empty():
		for i in opcoes.size():
			_habilitadas.append(true)
	_indice = 0
	for _opcao in opcoes:
		var label := Label.new()
		add_child(label)
		_labels.append(label)
	_atualizar()


func _mover(passo: int) -> void:
	# posmod faz a seleção "dar a volta": do último vai para o primeiro.
	_indice = posmod(_indice + passo, _labels.size())
	_atualizar()


func _atualizar() -> void:
	for i in _labels.size():
		var seta := "> " if i == _indice else "  "
		_labels[i].text = seta + str(_textos[i])
		_labels[i].modulate = Color.WHITE if _habilitadas[i] else COR_DESABILITADA
