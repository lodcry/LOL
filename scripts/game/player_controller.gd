extends Node2D

@export var velocidade: float = 220.0

var joystick: Control = null
var ws: Node = null
var _corpo: CharacterBody2D
var _sprite: ColorRect
var _nome_label: Label
var _timer_sync: float = 0.0
const SYNC_INTERVAL = 0.05

func _ready() -> void:
	_corpo = CharacterBody2D.new()
	add_child(_corpo)

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 24
	col.shape = shape
	_corpo.add_child(col)

	_sprite = ColorRect.new()
	_sprite.size = Vector2(48, 48)
	_sprite.position = Vector2(-24, -24)
	_sprite.color = Color(0.3, 0.6, 1.0)
	_corpo.add_child(_sprite)

	var circulo_borda = ColorRect.new()
	circulo_borda.size = Vector2(52, 52)
	circulo_borda.position = Vector2(-26, -26)
	circulo_borda.color = Color(0.5, 0.8, 1.0, 0.4)
	circulo_borda.z_index = -1
	_corpo.add_child(circulo_borda)

	_nome_label = Label.new()
	_nome_label.text = Boot.nome_jogador
	_nome_label.add_theme_font_size_override("font_size", 14)
	_nome_label.add_theme_color_override("font_color", Color.WHITE)
	_nome_label.position = Vector2(-40, -48)
	_nome_label.custom_minimum_size = Vector2(80, 0)
	_nome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_corpo.add_child(_nome_label)

	_corpo.position = Vector2(400, 4400)
	Console.adicionar_log("[PLAYER] Iniciado: %s" % Boot.nome_jogador)

func setup(j: Control, websocket: Node) -> void:
	joystick = j
	ws = websocket

func _physics_process(delta: float) -> void:
	if not joystick or not _corpo:
		return
	var dir = joystick.direcao
	_corpo.velocity = dir * velocidade
	_corpo.move_and_slide()
	_timer_sync += delta
	if _timer_sync >= SYNC_INTERVAL and ws:
		_timer_sync = 0.0
		ws.enviar_posicao(_corpo.position.x, _corpo.position.y)

func get_posicao() -> Vector2:
	return _corpo.position if _corpo else Vector2.ZERO
