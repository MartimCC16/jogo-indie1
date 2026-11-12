# ============================================================================
# formulas.gd  —  As CONTAS do combate (dano, cura, elementos)
# ----------------------------------------------------------------------------
# Tudo que é matemática de batalha fica aqui, num lugar só, para ficar fácil
# de balancear o jogo. "mult" é o multiplicador que vem do timing:
#   perfeito = 1.5   |   bom = 1.0   |   fraco = 0.6   (veja batalha.gd)
# ============================================================================
class_name Formulas
extends RefCounted

const MULT_FRAQUEZA := 1.5
const MULT_RESISTENCIA := 0.5
const REDUCAO_DEFENDENDO := 0.5   # quem escolheu Defender toma metade


## Uma pequena variação aleatória (90% a 110%) para o dano não ser sempre igual.
static func variacao() -> float:
	return randf_range(0.9, 1.1)


## Dano de um golpe físico (espada, mordida...).
static func dano_fisico(atacante: Combatente, alvo: Combatente, poder: float, mult: float) -> int:
	var bruto := atacante.ataque * poder * mult * variacao() - alvo.defesa * 0.5
	if alvo.defendendo:
		bruto *= REDUCAO_DEFENDENDO
	return maxi(1, roundi(bruto))


## Dano de uma magia. A defesa conta só um pouco contra magia.
static func dano_magico(atacante: Combatente, alvo: Combatente, magia: Dictionary, mult: float) -> int:
	var poder := float(magia.get("poder", 1.0))
	var bruto := atacante.magia * poder * mult * variacao() - alvo.defesa * 0.25
	if alvo.defendendo:
		bruto *= REDUCAO_DEFENDENDO
	return maxi(1, roundi(bruto))


## Quanto uma magia de cura recupera.
static func cura(atacante: Combatente, magia: Dictionary, mult: float) -> int:
	var poder := float(magia.get("poder", 1.0))
	return maxi(1, roundi(atacante.magia * poder * 1.5 * mult))


## 1.5 se o alvo é fraco ao elemento, 0.5 se resiste, 1.0 se normal.
static func multiplicador_elemento(alvo: Combatente, elemento: String) -> float:
	if elemento in alvo.fraquezas:
		return MULT_FRAQUEZA
	if elemento in alvo.resistencias:
		return MULT_RESISTENCIA
	return 1.0
