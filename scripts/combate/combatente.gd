# ============================================================================
# combatente.gd  —  Os dados de UM lutador durante a batalha
# ----------------------------------------------------------------------------
# Cada herói e cada inimigo vira um "Combatente" quando a batalha começa.
# Ele guarda a vida, a mana e os status, e aponta para o sprite na tela.
# Os valores iniciais vêm de data/herois.json e data/inimigos.json.
# (RefCounted = um objeto simples de dados, que não é um nó da cena.)
# ============================================================================
class_name Combatente
extends RefCounted

var id := ""
var nome := ""
var eh_heroi := false

var vida_max := 1
var vida := 1
var mana_max := 0
var mana := 0
var ataque := 1
var defesa := 0
var magia := 0
var velocidade := 1

var magias: Array = []         # ids de magias (heróis)
var ataques: Array = []        # lista de ataques (inimigos)
var fraquezas: Array = []      # elementos que causam dano x1.5
var resistencias: Array = []   # elementos que causam dano x0.5
var protege_aliados := false   # ao Defender, atrai os ataques (Sir Eco)
var chefe := false             # é um chefe?
var furia: Dictionary = {}     # chefes: fica mais forte com pouca vida
var furioso := false           # a fúria já foi ativada?

var defendendo := false        # escolheu "Defender" neste turno?

# Partes visuais (preenchidas pela batalha).
var sprite: Sprite2D = null
var posicao_base := Vector2.ZERO
var barra_vida: Barra = null       # só inimigos
var status: StatusHeroi = null     # só heróis


## Cria um Combatente a partir de um bloco de dados do JSON.
static func criar(id_combatente: String, dados: Dictionary, heroi: bool) -> Combatente:
	var c := Combatente.new()
	c.id = id_combatente
	c.nome = dados.get("nome", id_combatente)
	c.eh_heroi = heroi
	# Números do JSON chegam como "float"; int() transforma em inteiro.
	c.vida_max = int(dados.get("vida", 10))
	c.vida = c.vida_max
	c.mana_max = int(dados.get("mana", 0))
	c.mana = c.mana_max
	c.ataque = int(dados.get("ataque", 1))
	c.defesa = int(dados.get("defesa", 0))
	c.magia = int(dados.get("magia", 0))
	c.velocidade = int(dados.get("velocidade", 1))
	c.magias = dados.get("magias", [])
	c.ataques = dados.get("ataques", [])
	c.fraquezas = dados.get("fraquezas", [])
	c.resistencias = dados.get("resistencias", [])
	c.protege_aliados = dados.get("protege_aliados", false)
	c.chefe = dados.get("chefe", false)
	c.furia = dados.get("furia", {})
	return c


func esta_vivo() -> bool:
	return vida > 0


func receber_dano(quantidade: int) -> void:
	vida = maxi(0, vida - quantidade)


func curar(quantidade: int) -> void:
	vida = mini(vida_max, vida + quantidade)
