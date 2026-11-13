# ============================================================================
# floresta_entrada.gd  —  Floresta Cinzenta: a entrada (vinda da vila)
# ----------------------------------------------------------------------------
# Tudo que é comum a todo mapa vem do MapaBase. Aqui só fica a conversa
# da primeira vez que a Lia entra na floresta.
# ============================================================================
extends MapaBase

const DIALOGOS := "res://dialogues/floresta.json"


func _ao_entrar() -> void:
	mostrar_nome_regiao()
	if EstadoJogo.tem_flag("entrou_floresta"):
		return
	EstadoJogo.marcar_flag("entrou_floresta")
	lia.pode_mover = false
	await get_tree().create_timer(1.2).timeout  # deixa a tela clarear antes
	await Dialogo.iniciar(DIALOGOS, "floresta_chegada")
	lia.pode_mover = true
