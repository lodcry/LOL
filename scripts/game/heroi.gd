extends Node

var nome: String = ""
var posicao_role: String = ""
var hp_max: float = 600.0
var hp_atual: float = 600.0
var mana_max: float = 340.0
var mana_atual: float = 340.0
var nivel: int = 1
var xp: float = 0.0
var xp_proximo: float = 100.0
var ad_base: float = 60.0
var ap_base: float = 0.0
var ad_bonus: float = 0.0
var ap_bonus: float = 0.0
var armadura: float = 30.0
var resistencia_magica: float = 30.0
var velocidade_base: float = 330.0
var velocidade_ataque: float = 0.65
var alcance_ataque: float = 150.0
var hp_regen: float = 6.0
var mana_regen: float = 8.0
var vivo: bool = true
var invulneravel: bool = false
var red_buff: bool = false
var blue_buff: bool = false
var dragon_buffs: int = 0
var baron_buff: bool = false
var baron_buff_timer: float = 0.0
var slow_valor: float = 0.0
var slow_timer: float = 0.0

signal hp_mudou(atual, maximo)
signal mana_mudou(atual, maximo)
signal nivel_subiu(nivel)
signal morreu
signal reviveu

func configurar(dados: Dictionary) -> void:
	nome = dados.get("nome", "Herói")
	posicao_role = dados.get("posicao", "mid")
	hp_max = dados.get("hp_base", 600)
	hp_atual = hp_max
	mana_max = dados.get("recurso_max", 340)
	mana_atual = mana_max
	ad_base = dados.get("dano_base", 60)
	armadura = dados.get("armadura", 30)
	velocidade_base = dados.get("velocidade", 330)
	alcance_ataque = dados.get("alcance_ataque", 150)

func get_ad_total() -> float:
	return ad_base + ad_bonus

func get_ap_total() -> float:
	return ap_base + ap_bonus

func get_velocidade() -> float:
	var v = velocidade_base
	if baron_buff: v *= 1.15
	if slow_timer > 0: v *= (1.0 - slow_valor)
	return v

func receber_dano_fisico(dano: float, fonte: Node2D = null) -> void:
	if not vivo or invulneravel: return
	var real = dano * (100.0 / (100.0 + armadura))
	hp_atual = max(0, hp_atual - real)
	emit_signal("hp_mudou", hp_atual, hp_max)
	if hp_atual <= 0: _morrer(fonte)

func receber_dano_magico(dano: float, fonte: Node2D = null) -> void:
	if not vivo or invulneravel: return
	var real = dano * (100.0 / (100.0 + resistencia_magica))
	hp_atual = max(0, hp_atual - real)
	emit_signal("hp_mudou", hp_atual, hp_max)
	if hp_atual <= 0: _morrer(fonte)

func receber_dano(dano: float) -> void:
	receber_dano_fisico(dano)

func curar(valor: float) -> void:
	hp_atual = min(hp_max, hp_atual + valor)
	emit_signal("hp_mudou", hp_atual, hp_max)

func gastar_mana(custo: float) -> bool:
	if mana_atual < custo: return false
	mana_atual -= custo
	emit_signal("mana_mudou", mana_atual, mana_max)
	return true

func aplicar_slow(valor: float, duracao: float) -> void:
	slow_valor = max(slow_valor, valor)
	slow_timer = max(slow_timer, duracao)

func ganhar_xp(quantidade: float) -> void:
	xp += quantidade
	while xp >= xp_proximo:
		xp -= xp_proximo
		_subir_nivel()

func aplicar_red_buff() -> void:
	red_buff = true
	Console.adicionar_log("[BUFF] Red Buff ativado!")
	await get_tree().create_timer(90.0).timeout
	red_buff = false

func aplicar_blue_buff() -> void:
	blue_buff = true
	Console.adicionar_log("[BUFF] Blue Buff ativado!")
	await get_tree().create_timer(120.0).timeout
	blue_buff = false

func aplicar_baron_buff() -> void:
	baron_buff = true
	baron_buff_timer = 180.0
	Console.adicionar_log("[BUFF] Baron Buff ativado!")

func _subir_nivel() -> void:
	nivel += 1
	xp_proximo = nivel * 100.0
	hp_max += 80; hp_atual = hp_max
	mana_max += 30; mana_atual = mana_max
	ad_base += 4; armadura += 2; resistencia_magica += 1
	emit_signal("nivel_subiu", nivel)
	Console.adicionar_log("[HERÓI] Nível %d!" % nivel)

func _morrer(matador: Node2D = null) -> void:
	vivo = false
	if matador and is_instance_valid(matador):
		if matador.has_node("Inventario"):
			matador.get_node("Inventario").ganhar_ouro(300 + nivel * 20)
	emit_signal("morreu")
	var tempo_respawn = nivel * 2.5 + 10.0
	Console.adicionar_log("[HERÓI] Morreu. Respawn em %.0fs" % tempo_respawn)
	await get_tree().create_timer(tempo_respawn).timeout
	reviver()

func reviver() -> void:
	vivo = true
	hp_atual = hp_max
	mana_atual = mana_max
	emit_signal("reviveu")

func _process(delta: float) -> void:
	if not vivo: return
	if baron_buff:
		baron_buff_timer -= delta
		if baron_buff_timer <= 0: baron_buff = false
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0: slow_valor = 0.0
	hp_atual = min(hp_max, hp_atual + hp_regen * delta)
	var regen_mana = mana_regen * (1.5 if blue_buff else 1.0) * delta
	mana_atual = min(mana_max, mana_atual + regen_mana)
