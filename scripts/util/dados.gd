# ============================================================================
# dados.gd  —  Funções para ler arquivos de dados (JSON)
# ----------------------------------------------------------------------------
# Uso em qualquer script:   var herois := Dados.carregar_json("res://data/herois.json")
# "static" quer dizer que a função é usada direto pelo nome da classe (Dados),
# sem precisar criar um nó.
# ============================================================================
class_name Dados
extends RefCounted


## Lê um arquivo JSON e devolve um Dictionary (ou {} se der erro).
static func carregar_json(caminho: String) -> Dictionary:
	if not FileAccess.file_exists(caminho):
		push_error("Arquivo não encontrado: " + caminho)
		return {}
	var json := JSON.new()
	var erro := json.parse(FileAccess.get_file_as_string(caminho))
	if erro != OK:
		# Mostra a linha do erro: muito útil quando falta uma vírgula!
		push_error("Erro no JSON %s, linha %d: %s" % [caminho, json.get_error_line(), json.get_error_message()])
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("O JSON %s precisa começar com { e terminar com }" % caminho)
		return {}
	return json.data
