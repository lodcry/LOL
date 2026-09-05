extends Node2D

enum Estado {IDLE, MOVENDO, ATACANDO, VOLTANDO, MORTO}

var time_jogador: String = "vermelho"
var nome_jogador: String = "Bot"
var estado: Estado = Estado.IDLE
var rota: Array = []
var indice_rota: int = 0
var velocidade: float = 220.0
var alcance_ataque: float = 160.0
var timer_ataque: float = 0.0
var intervalo_ataque: float = 1.1
var alvo: Node2D = null
var vivo: bool = true
var hp_max: float = 600.0
var hp_atual: float = 600.0
var dano_ataque: float = 55.0
var _corpo: CharacterBody2D

signal morreu_sinal

func _ready() -> void:
	_corpo = CharacterBody2D.new()
	add_child(_corpo)
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 24
	col.shape = shape
	_corpo.add_child(col)
	var sprite = ColorRect.new()
	sprite.size = Vector2(44,44)
	sprite.position = Vector2(-22,-22)
	sprite.color = Color(0.9,0.2,0.2) if time_jogador == "vermelho" else Color(0.2,0.4,0.9)
	_corpo.add_child(sprite)
	var lbl = Label.new()
	lbl.text = nome_jogador
	lbl.position = Vector2(-30,-50)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	_corpo.add_child(lbl)
	add_to_group("jogadores")
	add_to_group("bots")

func configurar_rota(pontos: Array) -> void:
	rota = pontos

func _physics_process(delta: float) -> void:
	if not vivo: return
	match estado:
		Estado.IDLE: _buscar_alvo()
		Estado.MOVENDO: _mover(delta)
		Estado.ATACANDO: _atacar(delta)
		Estado.VOLTANDO: _voltar(delta)

func _buscar_alvo() -> void:
	var inimigo_time = "azul" if time_jogador == "vermelho" else "vermelho"
	var melhor: Node2D = null
	var menor = 600.0
	for grupo in ["jogadores", "minions"]:
		for j in get_tree().get_nodes_in_group(grupo):
			if not is_instance_valid(j) or j == self: continue
			if j.get("time_jogador") != inimigo_time: continue
			var d = _corpo.global_position.distance_to(j.global_position)
			if d < menor: menor = d; melhor = j
	if melhor: alvo = melhor; estado = Estado.ATACANDO
	elif not rota.is_empty(): estado = Estado.MOVENDO
	else: estado = Estado.IDLE

func _mover(delta: float) -> void:
	if rota.is_empty() or indice_rota >= rota.size():
		estado = Estado.IDLE; return
	var destino = rota[indice_rota]
	var dir = _corpo.global_position.direction_to(destino)
	_corpo.velocity = dir * velocidade
	_corpo.move_and_slide()
	if _corpo.global_position.distance_to(destino) < 50:
		indice_rota = (indice_rota + 1) % rota.size()
	_buscar_alvo()

func _atacar(delta: float) -> void:
	if not alvo or not is_instance_valid(alvo):
		alvo = null; estado = Estado.MOVENDO; return
	timer_ataque += delta
	var dist = _corpo.global_position.distance_to(alvo.global_position)
	if dist > alcance_ataque:
		_corpo.velocity = _corpo.global_position.direction_to(alvo.global_position) * velocidade
		_corpo.move_and_slide()
	if timer_ataque >= intervalo_ataque:
		timer_ataque = 0.0
		if alvo.has_method("receber_dano"): alvo.receber_dano(dano_ataque)
		Aggro.registrar(alvo, self, 5)

func _voltar(delta: float) -> void:
	if rota.is_empty(): estado = Estado.IDLE; return
	var base = rota[0]
	var dir = _corpo.global_position.direction_to(base)
	_corpo.velocity = dir * velocidade
	_corpo.move_and_slide()
	if _corpo.global_position.distance_to(base) < 100:
		estado = Estado.IDLE

func receber_dano(d: float) -> void:
	receber_dano_fisico(d)

func receber_dano_fisico(d: float, _fonte: Node2D = null) -> void:
	if not vivo: return
	hp_atual = max(0, hp_atual - d)
	if hp_atual <= 0: _morrer()

func receber_dano_magico(d: float, fonte: Node2D = null) -> void:
	receber_dano_fisico(d, fonte)

func _morrer() -> void:
	vivo = false
	emit_signal("morreu_sinal")
	_corpo.visible = false
	await get_tree().create_timer(15.0).timeout
	vivo = true
	hp_atual = hp_max
	_corpo.visible = true
	if not rota.is_empty():
		_corpo.global_position = rota[0]
	estado = Estado.IDLE
