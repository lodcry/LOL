extends Node2D

@export var velocidade: float = 330.0

var joystick: Control = null
var time_jogador: String = "azul"
var nome_jogador: String = ""
var _corpo: CharacterBody2D
var _sprite: ColorRect
var _timer_sync: float = 0.0
const SYNC_INTERVAL = 0.05
var _skill_executor: Node

func _ready() -> void:
	nome_jogador = Boot.nome_jogador
	time_jogador = Boot.time_jogador
	_corpo = CharacterBody2D.new()
	add_child(_corpo)
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new(); shape.radius = 24
	col.shape = shape; _corpo.add_child(col)
	_sprite = ColorRect.new()
	_sprite.size = Vector2(48,48)
	_sprite.position = Vector2(-24,-24)
	_sprite.color = Color(0.3,0.6,1.0) if time_jogador == "azul" else Color(1.0,0.3,0.3)
	_corpo.add_child(_sprite)
	var lbl = Label.new()
	lbl.text = nome_jogador
	lbl.position = Vector2(-40,-52)
	lbl.custom_minimum_size = Vector2(80,0)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color.WHITE)
	_corpo.add_child(lbl)
	_corpo.position = Vector2(400,4400) if time_jogador == "azul" else Vector2(4400,400)
	add_to_group("jogadores")
	var auto_s = load("res://scripts/game/auto_attack.gd")
	var aa = Node.new(); aa.set_script(auto_s)
	add_child(aa)
	_skill_executor = load("res://scripts/game/skill_executor.gd").new()
	add_child(_skill_executor)
	var inv_s = load("res://scripts/game/inventario.gd")
	var inv = Node.new(); inv.set_script(inv_s); inv.name = "Inventario"
	add_child(inv)
	inv.ouro_mudou.connect(func(o): Console.adicionar_log("[GOLD] %d" % o))

func setup(j: Control, _ws: Node) -> void:
	joystick = j

func _physics_process(delta: float) -> void:
	if not joystick or not _corpo: return
	var heroi = get_node_or_null("Heroi")
	if heroi and not heroi.vivo: return
	var vel = heroi.get_velocidade() if heroi else velocidade
	_corpo.velocity = joystick.direcao * vel
	_corpo.move_and_slide()
	_timer_sync += delta
	if _timer_sync >= SYNC_INTERVAL:
		_timer_sync = 0.0
		WS.enviar_posicao(_corpo.position.x, _corpo.position.y)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var heroi = get_node_or_null("Heroi")
		if not heroi: return
		var dados_heroi = _dados_heroi()
		var alvo_pos = _corpo.global_position + Vector2(200,0)
		match event.keycode:
			KEY_Q: _usar_skill(dados_heroi, 0, alvo_pos)
			KEY_W: _usar_skill(dados_heroi, 1, alvo_pos)
			KEY_E: _usar_skill(dados_heroi, 2, alvo_pos)
			KEY_R: _usar_skill(dados_heroi, 3, alvo_pos)
			KEY_P:
				var loja = get_tree().root.get_node_or_null("Partida/HUD/Loja")
				if loja: loja.visible = not loja.visible
			KEY_B:
				var loja = get_tree().root.get_node_or_null("Partida/HUD/Loja")
				if loja and is_near_base():
					loja.visible = not loja.visible

func _usar_skill(dados: Dictionary, idx: int, alvo_pos: Vector2) -> void:
	if dados.is_empty() or idx >= dados.get("skills_dados", []).size(): return
	var skill = dados.skills_dados[idx]
	var heroi = get_node_or_null("Heroi")
	if not heroi or not heroi.gastar_mana(skill.get("custo_mana", 50)): return
	_skill_executor.executar(skill, self, alvo_pos)

func _dados_heroi() -> Dictionary:
	const DADOS_HEROIS = {
		"lee_sin": {"skills_dados":[
			{"tipo":"PROJECTILE","dano":60,"escala_ad":0.9,"velocidade_projetil":1800,"alcance":1100,"custo_mana":50},
			{"tipo":"DASH","distancia":350,"custo_mana":30},
			{"tipo":"AREA","dano":80,"raio":250,"escala_ad":0.6,"custo_mana":40},
			{"tipo":"TARGETED","dano":200,"escala_ad":1.5,"tipo_dano":"fisico","custo_mana":100}]},
		"jinx": {"skills_dados":[
			{"tipo":"PROJECTILE","dano":110,"escala_ad":1.1,"velocidade_projetil":2200,"alcance":1400,"custo_mana":40},
			{"tipo":"PROJECTILE","dano":80,"escala_ad":0.7,"velocidade_projetil":3000,"alcance":1500,"custo_mana":40},
			{"tipo":"AREA","dano":100,"raio":100,"custo_mana":50},
			{"tipo":"PROJECTILE","dano":300,"escala_ad":1.5,"velocidade_projetil":1200,"alcance":5000,"custo_mana":100}]},
		"lux": {"skills_dados":[
			{"tipo":"PROJECTILE","dano":80,"escala_ap":0.8,"velocidade_projetil":1500,"alcance":1200,"custo_mana":50},
			{"tipo":"BUFF","efeito":"shield","duracao":2.5,"custo_mana":60},
			{"tipo":"AREA","dano":150,"raio":320,"escala_ap":1.0,"custo_mana":60},
			{"tipo":"AREA","dano":300,"raio":120,"escala_ap":1.4,"custo_mana":100}]},
		"darius": {"skills_dados":[
			{"tipo":"AREA","dano":120,"raio":340,"escala_ad":0.8,"custo_mana":30},
			{"tipo":"TARGETED","dano":50,"escala_ad":0.4,"tipo_dano":"fisico","custo_mana":30},
			{"tipo":"TARGETED","dano":80,"escala_ad":0.6,"tipo_dano":"fisico","custo_mana":45},
			{"tipo":"TARGETED","dano":400,"escala_ad":3.0,"tipo_dano":"fisico","custo_mana":100}]},
		"tryndamere": {"skills_dados":[
			{"tipo":"BUFF","efeito":"heal","dano":80,"escala_ad":0.3,"custo_mana":0},
			{"tipo":"AREA","dano":80,"raio":280,"custo_mana":40},
			{"tipo":"DASH","distancia":400,"custo_mana":60},
			{"tipo":"BUFF","efeito":"invulnerable","duracao":5.0,"custo_mana":0}]},
		"blitzcrank": {"skills_dados":[
			{"tipo":"PROJECTILE","dano":100,"escala_ap":0.7,"velocidade_projetil":1800,"alcance":1050,"custo_mana":100},
			{"tipo":"BUFF","efeito":"speed","bonus_velocidade":100,"duracao":2.0,"custo_mana":75},
			{"tipo":"TARGETED","dano":80,"escala_ap":0.5,"tipo_dano":"fisico","custo_mana":25},
			{"tipo":"AREA","dano":275,"raio":600,"escala_ap":1.0,"custo_mana":150}]},
		"leona": {"skills_dados":[
			{"tipo":"BUFF","efeito":"shield","duracao":1.5,"custo_mana":45},
			{"tipo":"BUFF","efeito":"shield","duracao":4.0,"custo_mana":60},
			{"tipo":"DASH","distancia":400,"custo_mana":60},
			{"tipo":"AREA","dano":250,"raio":400,"escala_ap":0.8,"custo_mana":100}]},
		"orianna": {"skills_dados":[
			{"tipo":"PROJECTILE","dano":80,"escala_ap":0.7,"velocidade_projetil":1200,"alcance":900,"custo_mana":40},
			{"tipo":"AREA","dano":70,"raio":225,"escala_ap":0.5,"custo_mana":60},
			{"tipo":"BUFF","efeito":"shield","duracao":2.0,"custo_mana":60},
			{"tipo":"AREA","dano":250,"raio":350,"escala_ap":1.0,"custo_mana":100}]},
		"draven": {"skills_dados":[
			{"tipo":"PROJECTILE","dano":80,"escala_ad":0.6,"velocidade_projetil":1400,"alcance":1000,"custo_mana":45},
			{"tipo":"BUFF","efeito":"speed","bonus_velocidade":90,"duracao":1.5,"custo_mana":40},
			{"tipo":"PROJECTILE","dano":70,"escala_ad":0.5,"velocidade_projetil":1600,"alcance":1050,"custo_mana":70},
			{"tipo":"PROJECTILE","dano":350,"escala_ad":1.1,"velocidade_projetil":2000,"alcance":20000,"custo_mana":100}]},
		"xin_zhao": {"skills_dados":[
			{"tipo":"TARGETED","dano":70,"escala_ad":0.7,"tipo_dano":"fisico","custo_mana":30},
			{"tipo":"AREA","dano":50,"raio":200,"escala_ad":0.5,"custo_mana":45},
			{"tipo":"DASH","distancia":400,"custo_mana":50},
			{"tipo":"AREA","dano":200,"raio":450,"escala_ad":1.0,"custo_mana":100}]}
	}
	return DADOS_HEROIS.get(Boot.heroi_selecionado, {})

func is_near_base() -> bool:
	var base_pos = Vector2(400,4400) if time_jogador == "azul" else Vector2(4400,400)
	return _corpo.global_position.distance_to(base_pos) < 600

func get_posicao() -> Vector2:
	return _corpo.position if _corpo else Vector2.ZERO
