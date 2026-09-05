extends Node2D

var camera: Camera2D
var player: Node2D
var joystick: Control
var minimapa: Control
var hud: CanvasLayer

func _ready() -> void:
	Engine.max_fps = 120
	_criar_mapa()
	_criar_player()
	_criar_camera()
	_criar_hud()
	WS.conectar_sala()
	WS.jogador_atualizado.connect(_on_jogador_atualizado)
	Console.adicionar_log("[PARTIDA] Mapa carregado")

func _criar_mapa() -> void:
	var mapa_script = load("res://scripts/game/mapa.gd")
	var mapa = Node2D.new()
	mapa.set_script(mapa_script)
	add_child(mapa)

func _criar_player() -> void:
	var ps = load("res://scripts/game/player_controller.gd")
	player = Node2D.new()
	player.set_script(ps)
	add_child(player)

func _criar_camera() -> void:
	camera = Camera2D.new()
	camera.zoom = Vector2(1.5, 1.5)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)
	camera.make_current()

func _criar_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)

	var js_script = load("res://scripts/game/joystick_touch.gd")
	joystick = Control.new()
	joystick.set_script(js_script)
	joystick.position = Vector2(30, 720 - 210)
	joystick.size = Vector2(180, 180)
	hud.add_child(joystick)

	var mini_script = load("res://scripts/game/minimapa.gd")
	minimapa = Control.new()
	minimapa.set_script(mini_script)
	minimapa.position = Vector2(1280 - 190, 720 - 190)
	minimapa.size = Vector2(180, 180)
	hud.add_child(minimapa)

	var nome_hud = Label.new()
	nome_hud.text = "⚡ " + Boot.nome_jogador
	nome_hud.position = Vector2(1280/2 - 80, 10)
	nome_hud.add_theme_font_size_override("font_size", 18)
	nome_hud.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	hud.add_child(nome_hud)

	if player.has_method("setup"):
		player.setup(joystick, WS)

func _process(_delta: float) -> void:
	if player and camera:
		camera.global_position = player.get_posicao()
	if minimapa and player:
		minimapa.atualizar_jogador(Boot.nome_jogador, player.get_posicao())

func _on_jogador_atualizado(id: String, x: float, y: float, nome: String) -> void:
	if minimapa:
		minimapa.atualizar_jogador(id, Vector2(x, y))
