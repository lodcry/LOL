extends Node2D

const CAMPS = [
	{"nome":"Red","pos":Vector2(3200,3200),"time_respawn":300,"tipo":"red","cor":Color(1,0.3,0.1),"hp":2000,"dano":120,"xp":200,"ouro":100},
	{"nome":"Blue","pos":Vector2(1600,1600),"time_respawn":300,"tipo":"blue","cor":Color(0.2,0.5,1),"hp":1800,"dano":100,"xp":200,"ouro":100},
	{"nome":"Red2","pos":Vector2(1600,3200),"time_respawn":300,"tipo":"red","cor":Color(1,0.3,0.1),"hp":2000,"dano":120,"xp":200,"ouro":100},
	{"nome":"Blue2","pos":Vector2(3200,1600),"time_respawn":300,"tipo":"blue","cor":Color(0.2,0.5,1),"hp":1800,"dano":100,"xp":200,"ouro":100},
	{"nome":"Dragon","pos":Vector2(3200,2600),"time_respawn":300,"tipo":"dragon","cor":Color(0.8,0.2,0.8),"hp":6000,"dano":200,"xp":500,"ouro":250},
	{"nome":"Baron","pos":Vector2(1600,2200),"time_respawn":420,"tipo":"baron","cor":Color(0.6,0.0,0.9),"hp":12000,"dano":300,"xp":900,"ouro":400},
]

var camp_nodes: Array = []
var dragon_kills_azul: int = 0
var dragon_kills_vermelho: int = 0

func _ready() -> void:
	for c in CAMPS:
		_spawnar_camp(c)

func _spawnar_camp(dados: Dictionary) -> void:
	var n = Node2D.new()
	n.global_position = dados.pos
	var hp = {"atual": dados.hp, "max": dados.hp}
	var sprite = ColorRect.new()
	sprite.size = Vector2(70,70)
	sprite.position = Vector2(-35,-35)
	sprite.color = dados.cor
	n.add_child(sprite)
	var lbl = Label.new()
	lbl.text = dados.nome
	lbl.position = Vector2(-25, -50)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	n.add_child(lbl)
	n.set_meta("dados", dados)
	n.set_meta("hp", hp)
	n.set_meta("vivo", true)
	camp_nodes.append(n)
	add_child(n)

func atacar_camp(camp_node: Node2D, dano: float, atacante: Node2D) -> void:
	if not camp_node.get_meta("vivo", false): return
	var hp = camp_node.get_meta("hp")
	hp.atual = max(0, hp.atual - dano)
	camp_node.set_meta("hp", hp)
	if hp.atual <= 0:
		_matar_camp(camp_node, atacante)

func _matar_camp(camp_node: Node2D, matador: Node2D) -> void:
	camp_node.set_meta("vivo", false)
	var dados = camp_node.get_meta("dados")
	if matador:
		if matador.has_node("Inventario"):
			matador.get_node("Inventario").ganhar_ouro(dados.ouro)
		if matador.has_node("Heroi"):
			var h = matador.get_node("Heroi")
			h.ganhar_xp(dados.xp)
			match dados.tipo:
				"red": h.aplicar_red_buff()
				"blue": h.aplicar_blue_buff()
	match dados.tipo:
		"dragon": _buff_dragon(matador)
		"baron": _buff_baron()
	Console.adicionar_log("[CAMP] %s morto por %s" % [dados.nome, matador.get("nome_jogador") if matador else "?"])
	for ch in camp_node.get_children(): ch.queue_free()
	await get_tree().create_timer(dados.time_respawn).timeout
	camp_node.set_meta("vivo", true)
	var hp = {"atual": dados.hp, "max": dados.hp}
	camp_node.set_meta("hp", hp)
	_respawnar_visual(camp_node, dados)

func _buff_dragon(matador: Node2D) -> void:
	var time = matador.get("time_jogador") if matador else ""
	if time == "azul": dragon_kills_azul += 1
	else: dragon_kills_vermelho += 1
	var kills = dragon_kills_azul if time == "azul" else dragon_kills_vermelho
	for j in get_tree().get_nodes_in_group("jogadores"):
		if j.get("time_jogador") != time: continue
		if j.has_node("Heroi"):
			var h = j.get_node("Heroi")
			h.ad_bonus += 8 * kills
			h.ap_bonus += 8 * kills
	Console.adicionar_log("🐉 Dragon buff aplicado! Stack %d" % kills)

func _buff_baron() -> void:
	for j in get_tree().get_nodes_in_group("jogadores"):
		if j.has_node("Heroi"):
			j.get_node("Heroi").aplicar_baron_buff()
	Console.adicionar_log("💜 Baron buff aplicado ao time!")

func _respawnar_visual(camp_node: Node2D, dados: Dictionary) -> void:
	var sprite = ColorRect.new()
	sprite.size = Vector2(70,70)
	sprite.position = Vector2(-35,-35)
	sprite.color = dados.cor
	camp_node.add_child(sprite)
	var lbl = Label.new()
	lbl.text = dados.nome
	lbl.position = Vector2(-25,-50)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	camp_node.add_child(lbl)
