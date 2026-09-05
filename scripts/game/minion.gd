extends CharacterBody2D

enum Estado {MOVENDO, ATACANDO, MORTO}

var time: String = "azul"
var time_jogador: String = "azul"
var tipo: String = "caster"
var velocidade: float = 175.0
var hp_max: float = 500.0
var hp_atual: float = 500.0
var dano: float = 25.0
var armadura: float = 20.0
var alcance_ataque: float = 120.0
var velocidade_ataque: float = 1.0
var ouro_kill: int = 65
var xp_kill: float = 40.0
var rota: Array = []
var indice_rota: int = 0
var estado: Estado = Estado.MOVENDO
var alvo: Node2D = null
var _timer_ataque: float = 0.0

signal morreu(time, ouro, xp, matador)

func _ready() -> void:
	time_jogador = time
	if tipo == "cannon":
		hp_max = 1200; hp_atual = hp_max
		dano = 60; armadura = 40
		ouro_kill = 90; xp_kill = 80
		velocidade = 150
	add_to_group("minions")
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20
	col.shape = shape
	add_child(col)
	var sprite = ColorRect.new()
	sprite.size = Vector2(30, 30)
	sprite.position = Vector2(-15, -15)
	sprite.color = Color(0.3,0.5,1.0) if time == "azul" else Color(1.0,0.3,0.3)
	add_child(sprite)
	if tipo == "cannon":
		sprite.size = Vector2(38, 38)
		sprite.position = Vector2(-19, -19)
		sprite.color = Color(0.1,0.2,0.9) if time == "azul" else Color(0.9,0.1,0.1)

func _physics_process(delta: float) -> void:
	if estado == Estado.MORTO: return
	_timer_ataque += delta
	_atualizar_alvo()
	match estado:
		Estado.MOVENDO: _mover(delta)
		Estado.ATACANDO: _atacar(delta)

func _atualizar_alvo() -> void:
	var alvo_aggro = Aggro.get_alvo(self)
	if alvo_aggro and is_instance_valid(alvo_aggro):
		alvo = alvo_aggro
		estado = Estado.ATACANDO
		return
	var mais_proximo: Node2D = null
	var menor = alcance_ataque * 3.0
	for grupo in ["minions", "jogadores", "bots"]:
		for n in get_tree().get_nodes_in_group(grupo):
			if not is_instance_valid(n): continue
			var n_time = n.get("time_jogador") if n.get("time_jogador") else ""
			if n_time == time: continue
			var d = global_position.distance_to(n.global_position)
			if d < menor: menor = d; mais_proximo = n
	if mais_proximo and menor <= alcance_ataque * 3.0:
		alvo = mais_proximo
		estado = Estado.ATACANDO
	else:
		estado = Estado.MOVENDO

func _mover(delta: float) -> void:
	if rota.is_empty() or indice_rota >= rota.size():
		return
	var destino = rota[indice_rota]
	var dir = global_position.direction_to(destino)
	velocity = dir * velocidade
	move_and_slide()
	if global_position.distance_to(destino) < 50:
		indice_rota += 1

func _atacar(delta: float) -> void:
	if not alvo or not is_instance_valid(alvo):
		alvo = null; Aggro.limpar(self); estado = Estado.MOVENDO; return
	var dist = global_position.distance_to(alvo.global_position)
	if dist > alcance_ataque:
		var dir = global_position.direction_to(alvo.global_position)
		velocity = dir * velocidade; move_and_slide()
	if _timer_ataque >= 1.0 / velocidade_ataque:
		_timer_ataque = 0.0
		if alvo.has_method("receber_dano"): alvo.receber_dano(dano)
		if alvo.has_method("get") and alvo.has_method("receber_dano"):
			Aggro.registrar(alvo, self, 1)

func receber_dano(d: float) -> void:
	receber_dano_fisico(d)

func receber_dano_fisico(d: float, fonte: Node2D = null) -> void:
	if estado == Estado.MORTO: return
	var real = d * (100.0 / (100.0 + armadura))
	hp_atual = max(0, hp_atual - real)
	if fonte: Aggro.registrar(self, fonte, 2)
	if hp_atual <= 0: _morrer(fonte)

func receber_dano_magico(d: float, fonte: Node2D = null) -> void:
	receber_dano_fisico(d, fonte)

func _morrer(matador: Node2D = null) -> void:
	estado = Estado.MORTO
	Aggro.limpar(self)
	emit_signal("morreu", time, ouro_kill, xp_kill, matador)
	queue_free()
