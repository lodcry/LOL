extends Node2D

var hp_max: float = 1800.0
var hp_atual: float = 1800.0
var time: String = "azul"
var time_jogador: String = "azul"
var dano: float = 90.0
var alcance: float = 850.0
var velocidade_ataque: float = 1.0
var _timer: float = 0.0
var destruida: bool = false
var _sprite: ColorRect

signal destruida_sinal(time)

func _ready() -> void:
	time_jogador = time
	add_to_group("torres")
	_sprite = ColorRect.new()
	_sprite.size = Vector2(60,60)
	_sprite.position = Vector2(-30,-30)
	_sprite.color = Color(0.3,0.5,1.0) if time == "azul" else Color(1.0,0.3,0.3)
	add_child(_sprite)

func _process(delta: float) -> void:
	if destruida: return
	_timer += delta
	if _timer >= 1.0 / velocidade_ataque:
		_timer = 0.0
		_atacar()

func _atacar() -> void:
	var alvo = _escolher_alvo()
	if not alvo: return
	if alvo.has_method("receber_dano_fisico"):
		alvo.receber_dano_fisico(dano, self)
	elif alvo.has_method("receber_dano"):
		alvo.receber_dano(dano)
	Console.adicionar_log("[TORRE] %s atacou por %.0f" % [time, dano])

func _escolher_alvo() -> Node2D:
	var inimigo_time = "vermelho" if time == "azul" else "azul"
	var candidatos = []
	for m in get_tree().get_nodes_in_group("minions"):
		if not is_instance_valid(m): continue
		if m.get("time") != inimigo_time: continue
		if global_position.distance_to(m.global_position) <= alcance:
			candidatos.append({"node": m, "prioridade": 10})
	for j in get_tree().get_nodes_in_group("jogadores"):
		if not is_instance_valid(j): continue
		if j.get("time_jogador") != inimigo_time: continue
		if global_position.distance_to(j.global_position) > alcance: continue
		var prio = 0
		if Aggro.get_alvo(j) and Aggro.get_alvo(j).get("time") == time:
			prio = 20
		candidatos.append({"node": j, "prioridade": prio})
	if candidatos.is_empty(): return null
	candidatos.sort_custom(func(a,b): return a.prioridade > b.prioridade)
	return candidatos[0].node

func receber_dano(d: float) -> void:
	receber_dano_fisico(d)

func receber_dano_fisico(d: float, _fonte: Node2D = null) -> void:
	if destruida: return
	hp_atual = max(0, hp_atual - d)
	if hp_atual <= 0: _destruir()

func _destruir() -> void:
	destruida = true
	emit_signal("destruida_sinal", time)
	Console.adicionar_log("[TORRE] Torre %s destruída!" % time)
	queue_free()
