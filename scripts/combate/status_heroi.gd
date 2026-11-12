# ============================================================================
# status_heroi.gd  —  Uma linha do painel de status: Nome [vida/mana] PV PM
# ----------------------------------------------------------------------------
# Criada por código pela batalha, uma para cada herói.
# Para mudar cores e tamanhos, mexa nas constantes abaixo.
# ============================================================================
class_name StatusHeroi
extends HBoxContainer

const COR_VIDA := Color("#e04848")
const COR_MANA := Color("#4a8cff")
const COR_DESTAQUE := Color("#ffd75a")   # nome de quem está jogando
const LARGURA_NOME := 44
const LARGURA_BARRAS := 60

var _nome := Label.new()
var _vida := Barra.new()
var _mana := Barra.new()
var _numeros := Label.new()


# _init roda quando o objeto é criado: aqui montamos os pedaços da linha.
func _init() -> void:
	add_theme_constant_override("separation", 4)

	_nome.custom_minimum_size = Vector2(LARGURA_NOME, 0)
	add_child(_nome)

	var barras := VBoxContainer.new()
	barras.add_theme_constant_override("separation", 1)
	barras.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_vida.custom_minimum_size = Vector2(LARGURA_BARRAS, 5)
	_vida.cor = COR_VIDA
	_mana.custom_minimum_size = Vector2(LARGURA_BARRAS, 4)
	_mana.cor = COR_MANA
	barras.add_child(_vida)
	barras.add_child(_mana)
	add_child(barras)

	_numeros.add_theme_font_size_override("font_size", 8)
	_numeros.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(_numeros)


## Atualiza nome, barras e números com os dados do combatente.
func mostrar(c: Combatente, animar := true) -> void:
	_nome.text = c.nome
	_vida.definir(float(c.vida) / c.vida_max, animar)
	_mana.definir(float(c.mana) / maxi(1, c.mana_max), animar)
	_numeros.text = "PV %d/%d  PM %d/%d" % [c.vida, c.vida_max, c.mana, c.mana_max]
	# Herói caído fica acinzentado.
	modulate = Color.WHITE if c.esta_vivo() else Color(0.5, 0.5, 0.5)


## Pinta o nome de amarelo quando é a vez deste herói.
func destacar(ativo: bool) -> void:
	if ativo:
		_nome.add_theme_color_override("font_color", COR_DESTAQUE)
	else:
		_nome.remove_theme_color_override("font_color")
