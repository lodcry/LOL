extends CharacterBody2D

@export var velocidade: float = 200.0
@onready var sprite: Sprite2D = $Sprite2D
@onready var nome_label: Label = $NomeLabel

var joystick: Control
var ws: Node
var _timer_sync: float = 0.0
const SYNC_INTERVAL: float = 0.05

func _ready() -> void:
	nome_label.text = Boot.nome_jogador
	Console.adicionar_log("[PLAYER] Iniciado: %s" % Boot.nome_jogador)

func setup(j: Control, websocket: Node) -> void:
	joystick = j
	ws = websocket

func _physics_process(delta: float) -> void:
	if not joystick:
		return
	var dir = joystick.direcao
	velocity = dir * velocidade
	move_and_slide()
	if dir.x != 0 and sprite:
		sprite.flip_h = dir.x < 0
	_timer_sync += delta
	if _timer_sync >= SYNC_INTERVAL and ws:
		_timer_sync = 0.0
		ws.enviar_posicao(global_position.x, global_position.y)
