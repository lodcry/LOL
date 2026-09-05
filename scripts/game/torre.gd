extends Node2D

var hp_max: float = 1500.0
var hp_atual: float = 1500.0
var time: String = "azul"
var dano: float = 80.0
var alcance: float = 200.0
var velocidade_ataque: float = 1.0
var _timer_ataque: float = 0.0
var destruida: bool = false
var alvo: Node2D = null

signal destruida_sinal(time)
signal atacou(alvo, dano)

func _ready() -> void:
	Console.adicionar_log("[TORRE] Torre %s criada com %d HP" % [time, hp_max])

func _process(delta: float) -> void:
	if destruida: return
	_timer_ataque += delta
	if _timer_ataque >= velocidade_ataque:
		_timer_ataque = 0.0
		_buscar_e_atacar()

func _buscar_e_atacar() -> void:
	var nos = get_tree().get_nodes_in_group("jogadores")
	var mais_proximo: Node2D = null
	var menor_dist = alcance
	for n in nos:
		if n.get("time_jogador") == time: continue
		var dist = global_position.distance_to(n.global_position)
		if dist < menor_dist:
			menor_dist = dist
			mais_proximo = n
	if mais_proximo:
		_atacar(mais_proximo)

func _atacar(alvo_node: Node2D) -> void:
	if alvo_node.has_method("receber_dano"):
		alvo_node.receber_dano(dano)
	emit_signal("atacou", alvo_node, dano)
	Console.adicionar_log("[TORRE] Torre %s atacou por %d" % [time, dano])

func receber_dano(d: float) -> void:
	if destruida: return
	hp_atual = max(0, hp_atual - d)
	if hp_atual <= 0:
		_destruir()

func _destruir() -> void:
	destruida = true
	emit_signal("destruida_sinal", time)
	Console.adicionar_log("[TORRE] Torre %s destruída!" % time)
	queue_free()
