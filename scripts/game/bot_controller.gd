extends Node2D

enum Estado {IDLE, MOVENDO, ATACANDO, VOLTANDO, MORTO}

var estado: Estado = Estado.IDLE
var heroi: Node = null
var rota: Array = []
var indice_rota: int = 0
var velocidade: float = 200.0
var alcance_ataque: float = 120.0
var timer_ataque: float = 0.0
var intervalo_ataque: float = 1.2
var alvo: Node2D = null
var time_bot: String = "vermelho"
var _corpo: CharacterBody2D

func _ready() -> void:
	_corpo = CharacterBody2D.new()
	add_child(_corpo)
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 24
	col.shape = shape
	_corpo.add_child(col)
	var sprite = ColorRect.new()
	sprite.size = Vector2(44, 44)
	sprite.position = Vector2(-22, -22)
	sprite.color = Color(0.9, 0.2, 0.2) if time_bot == "vermelho" else Color(0.2, 0.4, 0.9)
	_corpo.add_child(sprite)
	add_to_group("bots")
	Console.adicionar_log("[BOT] Bot %s criado" % time_bot)

func configurar_rota(pontos: Array) -> void:
	rota = pontos

func _physics_process(delta: float) -> void:
	match estado:
		Estado.IDLE: _buscar_alvo()
		Estado.MOVENDO: _mover(delta)
		Estado.ATACANDO: _atacar(delta)
		Estado.VOLTANDO: _voltar(delta)

func _buscar_alvo() -> void:
	var jogadores = get_tree().get_nodes_in_group("jogadores")
	for j in jogadores:
		if j.get("time_jogador") != time_bot:
			var dist = _corpo.global_position.distance_to(j.global_position)
			if dist < 400:
				alvo = j
				estado = Estado.ATACANDO
				return
	if rota.size() > 0:
		estado = Estado.MOVENDO

func _mover(delta: float) -> void:
	if rota.is_empty() or indice_rota >= rota.size():
		estado = Estado.IDLE
		return
	var destino = rota[indice_rota]
	var dir = (_corpo.global_position.direction_to(destino))
	_corpo.velocity = dir * velocidade
	_corpo.move_and_slide()
	if _corpo.global_position.distance_to(destino) < 40:
		indice_rota = (indice_rota + 1) % rota.size()
	_buscar_alvo()

func _atacar(delta: float) -> void:
	if not alvo or not is_instance_valid(alvo):
		alvo = null
		estado = Estado.MOVENDO
		return
	timer_ataque += delta
	var dist = _corpo.global_position.distance_to(alvo.global_position)
	if dist > alcance_ataque * 1.5:
		var dir = _corpo.global_position.direction_to(alvo.global_position)
		_corpo.velocity = dir * velocidade
		_corpo.move_and_slide()
	elif timer_ataque >= intervalo_ataque:
		timer_ataque = 0.0
		if alvo.has_method("receber_dano"):
			alvo.receber_dano(30.0 + randf_range(-5, 10))
