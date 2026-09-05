extends Node2D

var camera: Camera2D
var player: Node2D
var joystick: Control
var minimapa: Control
var hud: CanvasLayer
var loja: Control
var timer_partida: float = 0.0
var partida_ativa: bool = true

func _ready() -> void:
	Engine.max_fps = 120
	_criar_mapa()
	_criar_player()
	_criar_camera()
	_criar_hud()
	_criar_torres()
	_criar_nexus()
	_criar_bots()
	_criar_wave_manager()
	_criar_camp_manager()
	WS.conectar_sala(Boot.match_id)
	WS.jogador_atualizado.connect(_on_jogador_atualizado)
	Console.adicionar_log("[PARTIDA] Tudo pronto!")

func _criar_mapa() -> void:
	var m = Node2D.new()
	m.set_script(load("res://scripts/game/mapa.gd"))
	add_child(m)

func _criar_player() -> void:
	player = Node2D.new()
	player.set_script(load("res://scripts/game/player_controller.gd"))
	add_child(player)
	var heroi_node = Node.new()
	heroi_node.set_script(load("res://scripts/game/heroi.gd"))
	heroi_node.name = "Heroi"
	player.add_child(heroi_node)
	const DADOS_HEROIS = {
		"lee_sin":{"nome":"Lee Sin","posicao":"jungle","hp_base":650,"recurso_max":200,"dano_base":70,"armadura":33,"velocidade":345,"alcance_ataque":175},
		"jinx":{"nome":"Jinx","posicao":"adc","hp_base":560,"recurso_max":340,"dano_base":57,"armadura":26,"velocidade":325,"alcance_ataque":525},
		"lux":{"nome":"Lux","posicao":"mid","hp_base":520,"recurso_max":480,"dano_base":53,"armadura":21,"velocidade":330,"alcance_ataque":550},
		"darius":{"nome":"Darius","posicao":"top","hp_base":780,"recurso_max":340,"dano_base":79,"armadura":39,"velocidade":340,"alcance_ataque":175},
		"tryndamere":{"nome":"Tryndamere","posicao":"top","hp_base":720,"recurso_max":100,"dano_base":72,"armadura":35,"velocidade":345,"alcance_ataque":175},
		"blitzcrank":{"nome":"Blitzcrank","posicao":"support","hp_base":700,"recurso_max":440,"dano_base":62,"armadura":40,"velocidade":325,"alcance_ataque":175},
		"leona":{"nome":"Leona","posicao":"support","hp_base":750,"recurso_max":360,"dano_base":63,"armadura":42,"velocidade":335,"alcance_ataque":175},
		"orianna":{"nome":"Orianna","posicao":"mid","hp_base":530,"recurso_max":500,"dano_base":50,"armadura":22,"velocidade":325,"alcance_ataque":525},
		"draven":{"nome":"Draven","posicao":"adc","hp_base":580,"recurso_max":340,"dano_base":64,"armadura":28,"velocidade":330,"alcance_ataque":525},
		"xin_zhao":{"nome":"Xin Zhao","posicao":"jungle","hp_base":640,"recurso_max":280,"dano_base":68,"armadura":35,"velocidade":345,"alcance_ataque":175},
	}
	var dados = DADOS_HEROIS.get(Boot.heroi_selecionado, DADOS_HEROIS["lee_sin"])
	heroi_node.configurar(dados)
	heroi_node.morreu.connect(func(): _on_player_morreu())
	heroi_node.nivel_subiu.connect(func(n): Console.adicionar_log("⬆️ Nível %d!" % n))

func _criar_camera() -> void:
	camera = Camera2D.new()
	camera.zoom = Vector2(1.6,1.6)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)
	camera.make_current()

func _criar_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var js = Control.new()
	js.set_script(load("res://scripts/game/joystick_touch.gd"))
	js.position = Vector2(30, 720 - 210); js.size = Vector2(180,180)
	hud.add_child(js); joystick = js
	var mini = Control.new()
	mini.set_script(load("res://scripts/game/minimapa.gd"))
	mini.position = Vector2(1280 - 190, 720 - 190); mini.size = Vector2(180,180)
	hud.add_child(mini); minimapa = mini
	var loja_ctrl = Control.new()
	loja_ctrl.set_script(load("res://scripts/ui/loja_ui.gd"))
	loja_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	loja_ctrl.name = "Loja"; loja_ctrl.visible = false
	hud.add_child(loja_ctrl); loja = loja_ctrl
	var loja_node = loja_ctrl.get_node_or_null(".")
	if loja_node and player: loja_ctrl.set("inventario", player.get_node_or_null("Inventario"))
	_criar_barras_hud()
	if player.has_method("setup"): player.setup(joystick, WS)

func _criar_barras_hud() -> void:
	var bg = ColorRect.new()
	bg.position = Vector2(0,0); bg.size = Vector2(340,72)
	bg.color = Color(0,0,0,0.6); hud.add_child(bg)
	var heroi = player.get_node_or_null("Heroi")
	if not heroi: return
	var nm = Label.new(); nm.text = Boot.heroi_selecionado.to_upper()
	nm.position = Vector2(8,4); nm.add_theme_font_size_override("font_size",14)
	nm.add_theme_color_override("font_color", Color(0.4,0.8,1)); hud.add_child(nm)
	var hp_bar = ColorRect.new(); hp_bar.position = Vector2(8,24); hp_bar.size = Vector2(220,16)
	hp_bar.color = Color(0.2,0.8,0.3); hud.add_child(hp_bar)
	var mana_bar = ColorRect.new(); mana_bar.position = Vector2(8,44); mana_bar.size = Vector2(180,12)
	mana_bar.color = Color(0.3,0.4,1.0); hud.add_child(mana_bar)
	var ouro_lbl = Label.new(); ouro_lbl.position = Vector2(8,58)
	ouro_lbl.add_theme_font_size_override("font_size",14)
	ouro_lbl.add_theme_color_override("font_color", Color(0.95,0.8,0.2)); hud.add_child(ouro_lbl)
	var nivel_lbl = Label.new(); nivel_lbl.position = Vector2(240,24)
	nivel_lbl.add_theme_font_size_override("font_size",20)
	nivel_lbl.add_theme_color_override("font_color", Color.WHITE); hud.add_child(nivel_lbl)
	var timer_lbl = Label.new(); timer_lbl.position = Vector2(580,8)
	timer_lbl.add_theme_font_size_override("font_size",22)
	timer_lbl.add_theme_color_override("font_color", Color(0.9,0.7,0.2)); hud.add_child(timer_lbl)
	var inv = player.get_node_or_null("Inventario")
	if inv: inv.ouro_mudou.connect(func(o): ouro_lbl.text = "🪙 %d" % o)
	heroi.hp_mudou.connect(func(a,m): hp_bar.size.x = 220.0 * (a/m))
	heroi.mana_mudou.connect(func(a,m): mana_bar.size.x = 180.0 * (a/m))
	heroi.nivel_subiu.connect(func(n): nivel_lbl.text = "Lv%d" % n)
	set_meta("timer_lbl", timer_lbl)
	set_meta("nivel_lbl", nivel_lbl)
	nivel_lbl.text = "Lv1"
	ouro_lbl.text = "🪙 500"

func _criar_torres() -> void:
	const TORRES_AZUL = [
		Vector2(700,4300),Vector2(1400,4300),Vector2(700,400),Vector2(1400,400),
		Vector2(900,3900),Vector2(1600,3100),Vector2(2300,2300)
	]
	const TORRES_VERMELHO = [
		Vector2(4100,400),Vector2(3400,400),Vector2(4100,4300),Vector2(3400,4300),
		Vector2(3900,900),Vector2(3200,1700),Vector2(2500,2500)
	]
	for pos in TORRES_AZUL: _spawnar_torre(pos, "azul")
	for pos in TORRES_VERMELHO: _spawnar_torre(pos, "vermelho")

func _spawnar_torre(pos: Vector2, time: String) -> void:
	var t = Node2D.new()
	t.set_script(load("res://scripts/game/torre.gd"))
	t.global_position = pos
	t.time = time; t.time_jogador = time
	t.destruida_sinal.connect(func(_t): Console.adicionar_log("[TORRE] Torre %s caiu!" % time))
	add_child(t)

func _criar_nexus() -> void:
	for data in [{"time":"azul","pos":Vector2(300,4500)},{"time":"vermelho","pos":Vector2(4500,300)}]:
		var n = Node2D.new()
		n.set_script(load("res://scripts/game/nexus.gd"))
		n.global_position = data.pos
		n.time = data.time; n.time_jogador = data.time
		n.destruido_sinal.connect(_on_nexus_destruido)
		add_child(n)

func _criar_bots() -> void:
	var rotas = {
		"azul_bot1": [Vector2(400,4400),Vector2(400,2400),Vector2(400,400)],
		"vermelho_bot1": [Vector2(4400,400),Vector2(4400,2400),Vector2(4400,4400)],
		"azul_bot2": [Vector2(500,4300),Vector2(2400,2400),Vector2(4300,500)],
		"vermelho_bot2": [Vector2(4300,500),Vector2(2400,2400),Vector2(500,4300)],
	}
	for nome_bot in ["azul_bot1","azul_bot2"]:
		var b = Node2D.new()
		b.set_script(load("res://scripts/game/bot_controller.gd"))
		b.time_jogador = "azul"; b.nome_jogador = nome_bot
		add_child(b); b.configurar_rota(rotas[nome_bot])
	for nome_bot in ["vermelho_bot1","vermelho_bot2"]:
		var b = Node2D.new()
		b.set_script(load("res://scripts/game/bot_controller.gd"))
		b.time_jogador = "vermelho"; b.nome_jogador = nome_bot
		add_child(b); b.configurar_rota(rotas[nome_bot])

func _criar_wave_manager() -> void:
	var wm = Node.new()
	wm.set_script(load("res://scripts/game/wave_manager.gd"))
	add_child(wm)

func _criar_camp_manager() -> void:
	var cm = Node2D.new()
	cm.set_script(load("res://scripts/game/camp_manager.gd"))
	add_child(cm)

func _process(delta: float) -> void:
	if not partida_ativa: return
	timer_partida += delta
	if player and camera:
		camera.global_position = player.get_posicao()
	if minimapa and player:
		minimapa.atualizar_jogador(Boot.nome_jogador, player.get_posicao())
	var timer_lbl = get_meta("timer_lbl", null)
	if timer_lbl:
		var m = int(timer_partida / 60)
		var s = int(fmod(timer_partida, 60))
		timer_lbl.text = "%02d:%02d" % [m, s]

func _on_player_morreu() -> void:
	Console.adicionar_log("[PARTIDA] Você morreu!")

func _on_nexus_destruido(time_perdedor: String) -> void:
	partida_ativa = false
	var vencedor = "vermelho" if time_perdedor == "azul" else "azul"
	var vitoria = Boot.time_jogador == vencedor
	WS._enviar({"tipo":"fim_partida","vencedor":vencedor,"duracao":int(timer_partida)})
	Boot.ultima_partida = {"vitoria": vitoria, "duracao": int(timer_partida)}
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/fim_partida.tscn")

func _on_jogador_atualizado(id: String, x: float, y: float, nome: String) -> void:
	if minimapa: minimapa.atualizar_jogador(id, Vector2(x,y))
