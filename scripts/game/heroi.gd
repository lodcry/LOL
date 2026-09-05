extends Node2D

var nome: String = ""
var posicao_role: String = ""
var hp_max: float = 500.0
var hp_atual: float = 500.0
var mana_max: float = 300.0
var mana_atual: float = 300.0
var nivel: int = 1
var xp: float = 0.0
var xp_proximo: float = 100.0
var dano_base: float = 50.0
var armadura: float = 30.0
var velocidade_base: float = 330.0
var vivo: bool = true
var ouro: int = 500

signal hp_mudou(atual, maximo)
signal mana_mudou(atual, maximo)
signal nivel_subiu(nivel)
signal morreu
signal reviveu

func configurar(dados: Dictionary) -> void:
	nome = dados.get("nome", "Herói")
	posicao_role = dados.get("posicao", "mid")
	hp_max = dados.get("hp_base", 500)
	hp_atual = hp_max
	mana_max = dados.get("recurso_max", 300)
	mana_atual = mana_max
	dano_base = dados.get("dano_base", 50)
	armadura = dados.get("armadura", 30)
	velocidade_base = dados.get("velocidade", 330)

func receber_dano(dano: float) -> void:
	if not vivo: return
	var dano_real = dano * (100.0 / (100.0 + armadura))
	hp_atual = max(0, hp_atual - dano_real)
	emit_signal("hp_mudou", hp_atual, hp_max)
	if hp_atual <= 0:
		_morrer()

func curar(valor: float) -> void:
	hp_atual = min(hp_max, hp_atual + valor)
	emit_signal("hp_mudou", hp_atual, hp_max)

func gastar_mana(custo: float) -> bool:
	if mana_atual < custo: return false
	mana_atual -= custo
	emit_signal("mana_mudou", mana_atual, mana_max)
	return true

func ganhar_xp(quantidade: float) -> void:
	xp += quantidade
	while xp >= xp_proximo:
		xp -= xp_proximo
		_subir_nivel()

func _subir_nivel() -> void:
	nivel += 1
	xp_proximo = nivel * 100.0
	hp_max += 80
	hp_atual = hp_max
	mana_max += 30
	mana_atual = mana_max
	dano_base += 5
	armadura += 2
	emit_signal("nivel_subiu", nivel)
	Console.adicionar_log("[HERÓI] %s subiu para nível %d" % [nome, nivel])

func _morrer() -> void:
	vivo = false
	emit_signal("morreu")
	Console.adicionar_log("[HERÓI] %s morreu" % nome)

func reviver() -> void:
	vivo = true
	hp_atual = hp_max
	mana_atual = mana_max
	emit_signal("reviveu")
