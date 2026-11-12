# ============================================================================
# batalha.gd  —  A BATALHA POR TURNOS
# ----------------------------------------------------------------------------
# Como funciona (de cima para baixo):
#   1. _ready(): lê os dados (JSON), cria os sprites e o painel de status.
#   2. _rodar_batalha(): repete RODADAS até alguém vencer.
#      Em cada rodada, todos agem em ordem de VELOCIDADE (mais rápido primeiro).
#   3. Turno do herói: menu Atacar / Magia / Defender.
#      Atacar e Magia usam a BARRA DE TIMING (apertar na zona dourada).
#   4. Turno do inimigo: ele avança; aperte AÇÃO quando aparecer o "!" para
#      BLOQUEAR (dano reduzido a 1/4). Apertar ANTES do "!" não vale!
#   5. _finalizar(): vitória ou derrota.
#
# Como escolher o inimigo:
#   - Pelo código do mapa:  EstadoJogo.iniciar_batalha(["lobo_nevoa"], "res://...tscn", true)
#     (o "true" no final liga as dicas de TUTORIAL de dialogues/tutorial.json)
#   - Testando direto (F6 nesta cena): usa "Inimigos Padrao" do Inspetor.
#
# Os números (vida, ataque, magias...) ficam em data/*.json.
# As contas de dano ficam em scripts/combate/formulas.gd.
# ============================================================================
extends Node2D

## Inimigos usados quando a cena é rodada direto (F6), sem vir do mapa.
@export var inimigos_padrao: Array[String] = ["fiapo_nevoa"]
## Heróis usados quando a cena é rodada direto.
@export var herois_padrao: Array[String] = ["lia", "eco"]

const ARQ_HEROIS := "res://data/herois.json"
const ARQ_INIMIGOS := "res://data/inimigos.json"
const ARQ_MAGIAS := "res://data/magias.json"
const ARQ_TUTORIAL := "res://dialogues/tutorial.json"

# Onde cada lutador fica na tela (320x180).
const POSICOES_HEROIS := [Vector2(236, 58), Vector2(270, 92)]
const POSICOES_INIMIGOS := [Vector2(80, 76), Vector2(56, 48), Vector2(56, 102)]
const ESCALA_SPRITES := 2.0

# Multiplicador de dano para cada resultado da barra de timing.
const MULT_TIMING := {"perfeito": 1.5, "bom": 1.0, "fraco": 0.6}
# Defesa com timing: tempo (segundos) que o "!" fica na tela para apertar.
const JANELA_DEFESA := 0.35
# Quanto do dano passa quando o bloqueio dá certo.
const MULT_BLOQUEIO := 0.25
# PM recuperados ao escolher Defender.
const MANA_AO_DEFENDER := 2

const COR_PERFEITO := Color("#ffd75a")
const COR_CURA := Color("#7dff8a")
const COR_BLOQUEIO := Color("#8fe3ff")

var herois: Array[Combatente] = []
var inimigos: Array[Combatente] = []
var magias: Dictionary = {}

var _acabou := false
var _tutorial_ativo := false
var _textos_tutorial: Dictionary = {}
var _tutoriais_vistos: Dictionary = {}
var _venceu := false

@onready var combatentes_no: Node2D = $Combatentes
@onready var efeitos: Node2D = $Efeitos
@onready var mensagem: Label = $Interface/PainelMensagem/Mensagem
@onready var barra_timing: BarraTiming = $Interface/BarraTiming
@onready var alerta: Label = $Interface/Alerta
@onready var menu: MenuBatalha = $Interface/PainelMenu/Menu
@onready var lista_status: VBoxContainer = $Interface/PainelStatus/ListaStatus


func _ready() -> void:
	barra_timing.hide()
	alerta.hide()
	_preparar_combatentes()
	if inimigos.is_empty() or herois.is_empty():
		_texto("Erro: confira data/herois.json e data/inimigos.json")
		return
	_tutorial_ativo = EstadoJogo.proxima_batalha.get("tutorial", false)
	if _tutorial_ativo:
		_textos_tutorial = Dados.carregar_json(ARQ_TUTORIAL)
	var titulo := "%s aparece!" % inimigos[0].nome if inimigos.size() == 1 else "Inimigos aparecem!"
	if inimigos[0].chefe:
		titulo = "CHEFE: %s!" % inimigos[0].nome
	await _mensagem(titulo, 1.2)
	_rodar_batalha()


# ===========================================================================
# PREPARAÇÃO
# ===========================================================================

func _preparar_combatentes() -> void:
	# Se viemos do mapa, EstadoJogo diz quem luta. Se não, usamos os padrões.
	var config: Dictionary = EstadoJogo.proxima_batalha
	var ids_herois: Array = config.get("herois", herois_padrao)
	var ids_inimigos: Array = config.get("inimigos", inimigos_padrao)

	var dados_herois := Dados.carregar_json(ARQ_HEROIS)
	var dados_inimigos := Dados.carregar_json(ARQ_INIMIGOS)
	magias = Dados.carregar_json(ARQ_MAGIAS)

	for i in ids_herois.size():
		var id: String = ids_herois[i]
		if not dados_herois.has(id):
			push_error("Herói '%s' não existe em %s" % [id, ARQ_HEROIS])
			continue
		var c := Combatente.criar(id, dados_herois[id], true)
		c.sprite = _criar_sprite(dados_herois[id], POSICOES_HEROIS[i % POSICOES_HEROIS.size()])
		c.sprite.frame_coords = Vector2i(0, 2)  # linha 2 = olhando para a esquerda
		c.posicao_base = c.sprite.position
		c.status = StatusHeroi.new()
		lista_status.add_child(c.status)
		c.status.mostrar(c, false)
		herois.append(c)

	for i in ids_inimigos.size():
		var id: String = ids_inimigos[i]
		if not dados_inimigos.has(id):
			push_error("Inimigo '%s' não existe em %s" % [id, ARQ_INIMIGOS])
			continue
		var c := Combatente.criar(id, dados_inimigos[id], false)
		c.sprite = _criar_sprite(dados_inimigos[id], POSICOES_INIMIGOS[i % POSICOES_INIMIGOS.size()])
		c.sprite.flip_h = true  # inimigos são desenhados olhando para a esquerda
		c.posicao_base = c.sprite.position
		# Barra de vida embaixo do inimigo.
		var altura := c.sprite.texture.get_height() / c.sprite.vframes * ESCALA_SPRITES
		c.barra_vida = Barra.new()
		c.barra_vida.size = Vector2(40, 4)
		c.barra_vida.position = c.posicao_base + Vector2(-20, altura / 2.0 + 4)
		combatentes_no.add_child(c.barra_vida)
		inimigos.append(c)


func _criar_sprite(dados: Dictionary, posicao: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(dados.get("sprite", "res://icon.png"))
	s.hframes = int(dados.get("colunas", 1))
	s.vframes = int(dados.get("linhas", 1))
	s.scale = Vector2.ONE * ESCALA_SPRITES
	s.position = posicao
	combatentes_no.add_child(s)
	return s


# ===========================================================================
# LAÇO PRINCIPAL
# ===========================================================================

func _rodar_batalha() -> void:
	while not _acabou:
		for c in _ordem_dos_turnos():
			if _acabou:
				break
			if not c.esta_vivo():
				continue
			if c.eh_heroi:
				await _turno_heroi(c)
			else:
				await _turno_inimigo(c)
			_verificar_fim()
	await _finalizar()


## Todos os lutadores, do mais rápido para o mais lento.
func _ordem_dos_turnos() -> Array[Combatente]:
	var todos: Array[Combatente] = []
	todos.append_array(herois)
	todos.append_array(inimigos)
	todos.sort_custom(func(a: Combatente, b: Combatente) -> bool: return a.velocidade > b.velocidade)
	return todos


func _verificar_fim() -> void:
	if _vivos(inimigos).is_empty():
		_acabou = true
		_venceu = true
	elif _vivos(herois).is_empty():
		_acabou = true
		_venceu = false


# ===========================================================================
# TURNO DOS HERÓIS
# ===========================================================================

func _turno_heroi(c: Combatente) -> void:
	c.defendendo = false  # a defesa só vale até o próximo turno
	# Dicas de tutorial (só aparecem uma vez, e só se o tutorial estiver ligado).
	await _tutorial("tutorial_inicio")
	await _tutorial("tutorial_" + c.id)
	c.status.destacar(true)
	await _deslocar(c.sprite, c.posicao_base + Vector2(-10, 0), 0.15)  # dá um passo à frente
	_texto("Vez de %s" % c.nome)

	while true:
		var escolha := await menu.escolher(["Atacar", "Magia", "Defender"])
		if escolha == 0:
			await _heroi_atacar(c)
			break
		elif escolha == 1:
			var id_magia := await _escolher_magia(c)
			if id_magia == "":
				_texto("Vez de %s" % c.nome)
				continue  # cancelou: volta ao menu principal
			await _heroi_magia(c, id_magia)
			break
		elif escolha == 2:
			await _heroi_defender(c)
			break
		# escolha == -1 (cancelar no menu principal): não faz nada.

	await _deslocar(c.sprite, c.posicao_base, 0.15)
	c.status.destacar(false)


func _heroi_atacar(c: Combatente) -> void:
	var alvo := _primeiro_vivo(inimigos)
	_texto("Aperte AÇÃO na zona dourada!")
	var resultado := await barra_timing.executar()
	await _golpe(c, alvo)
	var dano := Formulas.dano_fisico(c, alvo, 1.0, MULT_TIMING[resultado])
	_aplicar_dano(alvo, dano, resultado)
	await _espera(0.7)


## Mostra o menu de magias e devolve o id da escolhida ("" se cancelou).
func _escolher_magia(c: Combatente) -> String:
	var opcoes: Array = []
	var habilitadas: Array = []
	var ids: Array = []
	for id in c.magias:
		if not magias.has(id):
			continue
		var m: Dictionary = magias[id]
		opcoes.append("%s %d" % [m.get("nome", id), int(m.get("custo", 0))])
		habilitadas.append(c.mana >= int(m.get("custo", 0)))
		ids.append(id)
	if ids.is_empty():
		await _mensagem("%s não conhece magias." % c.nome, 0.8)
		return ""
	_texto("Magia (número = custo em PM)")
	var i := await menu.escolher(opcoes, habilitadas)
	if i < 0:
		return ""
	return ids[i]


func _heroi_magia(c: Combatente, id_magia: String) -> void:
	var m: Dictionary = magias[id_magia]
	c.mana -= int(m.get("custo", 0))
	c.status.mostrar(c)
	await _mensagem("%s usa %s!" % [c.nome, m.get("nome", id_magia)], 0.6)

	_texto("Aperte AÇÃO na zona dourada!")
	var resultado := await barra_timing.executar()
	var mult: float = MULT_TIMING[resultado]
	var cor := Color.from_string(m.get("cor", "#ffffff"), Color.WHITE)

	if m.get("tipo", "dano") == "cura":
		var alvo := _heroi_mais_ferido()
		var quantidade := Formulas.cura(c, m, mult)
		alvo.curar(quantidade)
		alvo.status.mostrar(alvo)
		_brilho(alvo.sprite, cor)
		_numero("+%d" % quantidade, alvo.sprite.position, COR_CURA)
		if resultado == "perfeito":
			_numero("Perfeito!", alvo.sprite.position + Vector2(0, -14), COR_PERFEITO)
	else:
		var alvo := _primeiro_vivo(inimigos)
		var elemento := Formulas.multiplicador_elemento(alvo, m.get("elemento", ""))
		_brilho(alvo.sprite, cor)
		await _espera(0.2)
		var dano := Formulas.dano_magico(c, alvo, m, mult * elemento)
		_aplicar_dano(alvo, dano, resultado)
		if elemento > 1.0:
			_numero("Fraqueza!", alvo.sprite.position + Vector2(0, 26), cor)
		elif elemento < 1.0:
			_numero("Resiste...", alvo.sprite.position + Vector2(0, 26), Color.GRAY)
	await _espera(0.8)


func _heroi_defender(c: Combatente) -> void:
	c.defendendo = true
	c.mana = mini(c.mana_max, c.mana + MANA_AO_DEFENDER)
	c.status.mostrar(c)
	var extra := " e protege o grupo" if c.protege_aliados else ""
	await _mensagem("%s se defende%s! (+%d PM)" % [c.nome, extra, MANA_AO_DEFENDER], 1.0)


# ===========================================================================
# TURNO DOS INIMIGOS
# ===========================================================================

func _turno_inimigo(c: Combatente) -> void:
	c.defendendo = false
	var ataque: Dictionary = {"nome": "Ataque", "poder": 1.0, "alvo": "um"}
	if not c.ataques.is_empty():
		ataque = c.ataques.pick_random()

	var alvos := _escolher_alvos(ataque)
	if alvos.is_empty():
		return

	await _verificar_furia(c)
	await _tutorial("tutorial_defesa")
	await _mensagem("%s usa %s!" % [c.nome, ataque.get("nome", "Ataque")], 0.8)
	_texto("Aperte AÇÃO quando aparecer o  !")
	var bloqueou := await _investida_com_defesa(c, alvos[0])

	for alvo in alvos:
		var dano := Formulas.dano_fisico(c, alvo, float(ataque.get("poder", 1.0)), 1.0)
		if bloqueou:
			dano = maxi(1, roundi(dano * MULT_BLOQUEIO))
		_aplicar_dano(alvo, dano, "bloqueio" if bloqueou else "")
	if bloqueou:
		_numero("Bloqueou!", alvos[0].sprite.position + Vector2(0, -14), COR_BLOQUEIO)
	await _espera(0.8)


## Chefes com "furia" no JSON ficam mais fortes quando a vida cai.
func _verificar_furia(c: Combatente) -> void:
	if c.furioso or c.furia.is_empty():
		return
	if float(c.vida) / c.vida_max > float(c.furia.get("limite", 0.5)):
		return
	c.furioso = true
	c.ataque += int(c.furia.get("ataque_extra", 0))
	# Fica avermelhado para mostrar a fúria.
	create_tween().tween_property(c.sprite, "modulate", Color(1, 0.65, 0.65), 0.4)
	await _mensagem(c.furia.get("mensagem", "%s ficou furioso!" % c.nome), 1.4)
	await _tutorial("tutorial_furia")


## Quem o inimigo vai atacar.
func _escolher_alvos(ataque: Dictionary) -> Array[Combatente]:
	var vivos := _vivos(herois)
	if vivos.is_empty() or ataque.get("alvo", "um") == "todos":
		return vivos
	# Um aliado protetor (Sir Eco) defendendo atrai o ataque para si.
	var alvos: Array[Combatente] = []
	for h in vivos:
		if h.protege_aliados and h.defendendo:
			alvos.append(h)
			return alvos
	alvos.append(vivos.pick_random())
	return alvos


## O inimigo recua, avança e o jogador tem uma janela curta para bloquear.
## Devolve true se o bloqueio deu certo.
func _investida_com_defesa(atacante: Combatente, alvo: Combatente) -> bool:
	# Tempo de "preparo" aleatório, para o jogador não decorar o ritmo.
	var preparo := randf_range(0.5, 1.1)
	var origem := atacante.posicao_base
	var destino := alvo.sprite.position + Vector2(-30, 0)

	var tween := create_tween()
	tween.tween_property(atacante.sprite, "position", origem + Vector2(-6, 0), preparo)  # recua
	tween.tween_property(atacante.sprite, "position", destino, JANELA_DEFESA)          # avança

	alerta.position = alvo.sprite.position + Vector2(-4, -44)
	var bloqueou := await _esperar_aperto(preparo, JANELA_DEFESA)

	if tween.is_running():
		await tween.finished
	_deslocar(atacante.sprite, origem, 0.3)  # volta (sem esperar)
	return bloqueou


## Espera "antes" segundos e depois mostra o "!" por "janela" segundos.
## Devolve true só se AÇÃO for apertada enquanto o "!" está na tela.
func _esperar_aperto(antes: float, janela: float) -> bool:
	var tempo := 0.0
	var resultado := false
	alerta.hide()
	# Ignora um aperto que tenha acontecido neste mesmo quadro (ex.: fechar diálogo).
	await get_tree().process_frame
	while tempo < antes + janela:
		await get_tree().process_frame
		tempo += get_process_delta_time()
		if tempo >= antes and not alerta.visible:
			alerta.show()
		if Input.is_action_just_pressed("acao"):
			resultado = tempo >= antes  # apertou cedo demais = falhou
			break
	alerta.hide()
	return resultado


# ===========================================================================
# FIM DA BATALHA
# ===========================================================================

func _finalizar() -> void:
	menu.limpar()
	# Guarda uma cópia da configuração (para "tentar de novo").
	var config: Dictionary = EstadoJogo.proxima_batalha.duplicate()
	var retorno: String = config.get("cena_retorno", "")

	if not _venceu:
		await _mensagem("Lia e Sir Eco caíram...", 1.5)
		_texto("Aperte AÇÃO para tentar de novo")
		await _esperar_acao()
		if retorno != "":
			EstadoJogo.repetir_batalha(config)
		else:
			get_tree().reload_current_scene()
		return

	await _mensagem("Vitória!", 1.5)
	EstadoJogo.registrar_fim_batalha(true)
	if retorno != "":
		EstadoJogo.trocar_cena(retorno)
	else:
		# Rodando a cena direto (F6): permite lutar de novo.
		_texto("Aperte AÇÃO para lutar de novo")
		await _esperar_acao()
		get_tree().reload_current_scene()


## Mostra um diálogo de tutorial (uma vez só por batalha).
func _tutorial(id: String) -> void:
	if not _tutorial_ativo or _tutoriais_vistos.has(id) or not _textos_tutorial.has(id):
		return
	_tutoriais_vistos[id] = true
	await Dialogo.iniciar(ARQ_TUTORIAL, id)


# ===========================================================================
# AJUDANTES (efeitos visuais, mensagens, listas)
# ===========================================================================

func _aplicar_dano(alvo: Combatente, dano: int, resultado: String) -> void:
	alvo.receber_dano(dano)
	_piscar(alvo.sprite)
	var cor := Color.WHITE
	if resultado == "perfeito":
		cor = COR_PERFEITO
		_numero("Perfeito!", alvo.sprite.position + Vector2(0, -14), COR_PERFEITO)
	elif resultado == "bloqueio":
		cor = COR_BLOQUEIO
	_numero(str(dano), alvo.sprite.position, cor)
	_atualizar_visual(alvo)


func _atualizar_visual(c: Combatente) -> void:
	if c.eh_heroi:
		c.status.mostrar(c)
		if not c.esta_vivo():
			# Herói caído fica escuro (espera o "piscar" de dano acabar).
			create_tween().tween_property(c.sprite, "modulate", Color(0.4, 0.4, 0.45), 0.3).set_delay(0.3)
	else:
		c.barra_vida.definir(float(c.vida) / c.vida_max)
		if not c.esta_vivo():
			# Inimigo derrotado some aos poucos.
			var tween := create_tween()
			tween.tween_interval(0.3)  # espera o "piscar" de dano acabar
			tween.tween_property(c.sprite, "modulate:a", 0.0, 0.6)
			tween.parallel().tween_property(c.barra_vida, "modulate:a", 0.0, 0.6)


## O herói corre até o inimigo e volta.
func _golpe(atacante: Combatente, alvo: Combatente) -> void:
	var perto := alvo.sprite.position + Vector2(30, 0)
	await _deslocar(atacante.sprite, perto, 0.12)
	await _deslocar(atacante.sprite, atacante.posicao_base + Vector2(-10, 0), 0.15)


func _deslocar(no: Node2D, destino: Vector2, tempo: float) -> void:
	var tween := create_tween()
	tween.tween_property(no, "position", destino, tempo)
	await tween.finished


## Pisca em vermelho (levou dano).
func _piscar(sprite: Sprite2D) -> void:
	var cor_final := sprite.modulate
	var tween := create_tween()
	for i in 2:
		tween.tween_property(sprite, "modulate", Color(1, 0.3, 0.3, cor_final.a), 0.06)
		tween.tween_property(sprite, "modulate", cor_final, 0.06)


## Brilha com a cor da magia.
func _brilho(sprite: Sprite2D, cor: Color) -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", cor, 0.15)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)


## Número (ou palavra) que sobe e some em cima de alguém.
func _numero(texto: String, posicao: Vector2, cor: Color) -> void:
	var label := Label.new()
	label.text = texto
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", cor)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.08))
	label.add_theme_constant_override("outline_size", 3)
	label.size = Vector2(70, 14)
	label.position = posicao + Vector2(-35, -30)
	efeitos.add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 12, 0.7)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.4)
	tween.tween_callback(label.queue_free)


## Troca o texto da mensagem do topo (sem esperar).
func _texto(texto: String) -> void:
	mensagem.text = texto


## Mostra uma mensagem e espera alguns segundos.
func _mensagem(texto: String, segundos: float) -> void:
	_texto(texto)
	await _espera(segundos)


func _espera(segundos: float) -> void:
	await get_tree().create_timer(segundos).timeout


func _esperar_acao() -> void:
	await get_tree().process_frame
	while not Input.is_action_just_pressed("acao"):
		await get_tree().process_frame


func _vivos(lista: Array[Combatente]) -> Array[Combatente]:
	var resultado: Array[Combatente] = []
	for c in lista:
		if c.esta_vivo():
			resultado.append(c)
	return resultado


func _primeiro_vivo(lista: Array[Combatente]) -> Combatente:
	for c in lista:
		if c.esta_vivo():
			return c
	return null


func _heroi_mais_ferido() -> Combatente:
	var escolhido: Combatente = null
	for h in _vivos(herois):
		if escolhido == null or float(h.vida) / h.vida_max < float(escolhido.vida) / escolhido.vida_max:
			escolhido = h
	return escolhido
