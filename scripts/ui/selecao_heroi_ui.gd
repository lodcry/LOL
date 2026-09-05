extends Control

const HEROIS = [
	{"id":"lee_sin","nome":"Lee Sin","posicao":"Jungle","dificuldade":"Alto","cor":Color(0.8,0.4,0.1),"icone":"🥋","desc":"Monge cego do dragão espiritual","skills":["Sonic Wave","Safeguard","Tempest","Dragon Rage"]},
	{"id":"xin_zhao","nome":"Xin Zhao","posicao":"Jungle","dificuldade":"Baixo","cor":Color(0.3,0.5,0.9),"icone":"🗡️","desc":"General leal de mil batalhas","skills":["Three Talon Strike","Wind Becomes Lightning","Audacious Charge","Crescent Guard"]},
	{"id":"jinx","nome":"Jinx","posicao":"ADC","dificuldade":"Médio","cor":Color(0.7,0.2,0.8),"icone":"💜","desc":"Caos puro em forma humana","skills":["Switcheroo","Zap","Flame Chompers","Super Mega Death Rocket"]},
	{"id":"draven","nome":"Draven","posicao":"ADC","dificuldade":"Alto","cor":Color(0.9,0.2,0.1),"icone":"🪓","desc":"Carrasco que virou espetáculo","skills":["Spinning Axe","Blood Rush","Stand Aside","Whirling Death"]},
	{"id":"lux","nome":"Lux","posicao":"Mid","dificuldade":"Baixo","cor":Color(0.9,0.8,0.1),"icone":"✨","desc":"Maga da luz de Demacia","skills":["Light Binding","Prismatic Barrier","Lucent Singularity","Final Spark"]},
	{"id":"orianna","nome":"Orianna","posicao":"Mid","dificuldade":"Alto","cor":Color(0.3,0.8,0.9),"icone":"⚙️","desc":"Autômato que imita humanidade","skills":["Command Attack","Command Dissonance","Command Protect","Command Shockwave"]},
	{"id":"blitzcrank","nome":"Blitzcrank","posicao":"Support","dificuldade":"Médio","cor":Color(0.9,0.7,0.1),"icone":"🤖","desc":"Golem a vapor com empatia própria","skills":["Rocket Grab","Overdrive","Power Fist","Static Field"]},
	{"id":"leona","nome":"Leona","posicao":"Support","dificuldade":"Baixo","cor":Color(0.9,0.6,0.1),"icone":"☀️","desc":"Paladina do Sol dos Rakkor","skills":["Shield of Daybreak","Eclipse","Zenith Blade","Solar Flare"]},
	{"id":"darius","nome":"Darius","posicao":"Top","dificuldade":"Médio","cor":Color(0.8,0.1,0.1),"icone":"⚔️","desc":"A mão de Noxus","skills":["Decimate","Crippling Strike","Apprehend","Noxian Guillotine"]},
	{"id":"tryndamere","nome":"Tryndamere","posicao":"Top","dificuldade":"Médio","cor":Color(0.7,0.3,0.1),"icone":"🔥","desc":"Bárbaro consumido por fúria imortal","skills":["Bloodlust","Mocking Shout","Spinning Slash","Undying Rage"]},
]

const RUNAS = [
	{"nome":"Conquistador","desc":"Ataques geram stacks, maximizado causa dano bônus","tipo":"ofensiva","cor":Color(0.9,0.6,0.1)},
	{"nome":"Eletrocutar","desc":"3 ataques seguidos causam burst de dano","tipo":"ofensiva","cor":Color(0.7,0.2,0.9)},
	{"nome":"Fleet Footwork","desc":"Ataques geram energia que ao maximizar cura e dá velocidade","tipo":"sustain","cor":Color(0.2,0.7,0.9)},
	{"nome":"Aperto dos Mortos","desc":"Imobilizar inimigos aumenta dano subsequente","tipo":"controle","cor":Color(0.5,0.1,0.8)},
	{"nome":"Predador","desc":"Dash ativa boost de velocidade e dano","tipo":"mobilidade","cor":Color(0.1,0.8,0.4)},
	{"nome":"Fase da Vida","desc":"Ataques básicos causam dano bônus baseado no HP máximo","tipo":"tanque","cor":Color(0.8,0.2,0.2)},
]

const PODERES = ["Flash","Ghost","Smite","Ignite","Heal","Barrier","Exhaust","Teleport"]
const ICONES_PODERES = ["⚡","👻","🎯","🔥","💚","🛡️","😴","🌀"]

var heroi_selecionado: int = 0
var runa_selecionada: int = 0
var poderes_selecionados: Array = [0, 2]
var aba_atual: String = "heroi"

var painel_info: Control
var viewport_3d: SubViewport
var heroi_visual: Node3D
var grid_herois: Control
var painel_runas: Control
var painel_poderes: Control
var btn_confirmar: Button

func _ready() -> void:
	Engine.max_fps = 120
	_criar_ui_completa()

func _criar_ui_completa() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.1)
	add_child(bg)

	var main = HBoxContainer.new()
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.add_theme_constant_override("separation", 0)
	add_child(main)

	# Coluna esquerda — lista de heróis
	var col_esq = VBoxContainer.new()
	col_esq.custom_minimum_size = Vector2(260, 0)
	col_esq.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_esq.add_theme_constant_override("separation", 0)
	main.add_child(col_esq)

	var header = ColorRect.new()
	header.custom_minimum_size = Vector2(0, 60)
	header.color = Color(0.08,0.08,0.18)
	col_esq.add_child(header)
	var header_lbl = Label.new()
	header_lbl.text = "HERÓIS"
	header_lbl.add_theme_font_size_override("font_size", 18)
	header_lbl.add_theme_color_override("font_color", Color(0.4,0.8,1.0))
	header_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	header_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(header_lbl)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_esq.add_child(scroll)

	grid_herois = VBoxContainer.new()
	grid_herois.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_herois.add_theme_constant_override("separation", 4)
	scroll.add_child(grid_herois)

	for i in HEROIS.size():
		var h = HEROIS[i]
		var card = _criar_card_heroi(h, i)
		grid_herois.add_child(card)

	# Coluna central — visualização 3D e info
	var col_mid = VBoxContainer.new()
	col_mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_mid.add_theme_constant_override("separation", 8)
	main.add_child(col_mid)

	# Viewport 3D do herói
	var vp_container = SubViewportContainer.new()
	vp_container.custom_minimum_size = Vector2(0, 340)
	vp_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vp_container.stretch = true
	col_mid.add_child(vp_container)

	viewport_3d = SubViewport.new()
	viewport_3d.transparent_bg = true
	vp_container.add_child(viewport_3d)

	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.06, 0.06, 0.14)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.4, 0.8)
	env.ambient_light_energy = 0.8
	env_node.environment = env
	viewport_3d.add_child(env_node)

	var cam3d = Camera3D.new()
	cam3d.position = Vector3(0, 1.5, 4)
	cam3d.look_at(Vector3(0, 1, 0))
	viewport_3d.add_child(cam3d)

	var luz = DirectionalLight3D.new()
	luz.position = Vector3(2, 4, 2)
	luz.look_at(Vector3.ZERO)
	luz.light_energy = 1.2
	viewport_3d.add_child(luz)

	var luz2 = OmniLight3D.new()
	luz2.position = Vector3(-2, 2, 1)
	luz2.light_energy = 0.6
	luz2.light_color = Color(0.4, 0.6, 1.0)
	viewport_3d.add_child(luz2)

	heroi_visual = _criar_modelo_3d(0)
	viewport_3d.add_child(heroi_visual)

	# Abas
	var abas = HBoxContainer.new()
	abas.add_theme_constant_override("separation", 4)
	col_mid.add_child(abas)

	for aba in [["heroi","HERÓI"], ["runas","RUNAS"], ["poderes","PODERES"]]:
		var btn = Button.new()
		btn.text = aba[1]
		btn.custom_minimum_size = Vector2(0, 44)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 16)
		var id = aba[0]
		btn.pressed.connect(func(): _mudar_aba(id))
		abas.add_child(btn)

	# Painel herói info
	painel_info = _criar_painel_heroi_info()
	col_mid.add_child(painel_info)

	# Painel runas
	painel_runas = _criar_painel_runas()
	painel_runas.visible = false
	col_mid.add_child(painel_runas)

	# Painel poderes
	painel_poderes = _criar_painel_poderes()
	painel_poderes.visible = false
	col_mid.add_child(painel_poderes)

	# Botão confirmar
	btn_confirmar = Button.new()
	btn_confirmar.text = "⚔️  CONFIRMAR E ENTRAR NA FILA"
	btn_confirmar.custom_minimum_size = Vector2(0, 64)
	btn_confirmar.add_theme_font_size_override("font_size", 22)
	var s_conf = StyleBoxFlat.new()
	s_conf.bg_color = Color(0.1,0.4,0.8)
	s_conf.corner_radius_top_left = 10
	s_conf.corner_radius_top_right = 10
	s_conf.corner_radius_bottom_left = 10
	s_conf.corner_radius_bottom_right = 10
	btn_confirmar.add_theme_stylebox_override("normal", s_conf)
	btn_confirmar.pressed.connect(_confirmar_selecao)
	col_mid.add_child(btn_confirmar)

	_atualizar_info_heroi()

func _criar_modelo_3d(idx: int) -> Node3D:
	var h = HEROIS[idx]
	var root = Node3D.new()

	var corpo = MeshInstance3D.new()
	var capsule = CapsuleMesh.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	corpo.mesh = capsule
	corpo.position = Vector3(0, 0.9, 0)

	var mat = StandardMaterial3D.new()
	mat.albedo_color = h.cor
	mat.roughness = 0.3
	mat.metallic = 0.7
	mat.emission_enabled = true
	mat.emission = h.cor * 0.3
	corpo.material_override = mat
	root.add_child(corpo)

	var cabeca = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.25
	sphere.height = 0.5
	cabeca.mesh = sphere
	cabeca.position = Vector3(0, 2.0, 0)
	var mat2 = StandardMaterial3D.new()
	mat2.albedo_color = h.cor.lightened(0.3)
	mat2.metallic = 0.5
	cabeca.material_override = mat2
	root.add_child(cabeca)

	var aura = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.35
	torus.outer_radius = 0.55
	aura.mesh = torus
	aura.position = Vector3(0, 0.1, 0)
	var mat3 = StandardMaterial3D.new()
	mat3.albedo_color = h.cor
	mat3.emission_enabled = true
	mat3.emission = h.cor
	mat3.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat3.albedo_color.a = 0.7
	aura.material_override = mat3
	root.add_child(aura)

	var spin = Tween.new()
	root.add_child(spin)

	return root

func _process(delta: float) -> void:
	if heroi_visual:
		heroi_visual.rotation_degrees.y += 40 * delta

func _criar_card_heroi(h: Dictionary, idx: int) -> Control:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 64)
	btn.pressed.connect(func(): _selecionar_heroi(idx))

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1,0.1,0.2,0.9)
	style.border_color = h.cor * 0.7
	style.border_width_left = 3
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", style)

	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 12)
	btn.add_child(hbox)

	var mg = MarginContainer.new()
	mg.add_theme_constant_override("margin_left", 12)
	mg.add_theme_constant_override("margin_top", 8)
	mg.add_theme_constant_override("margin_bottom", 8)
	mg.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.add_child(mg)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	mg.add_child(row)

	var icone_rect = ColorRect.new()
	icone_rect.custom_minimum_size = Vector2(44, 44)
	icone_rect.color = h.cor * 0.5
	row.add_child(icone_rect)

	var ic_lbl = Label.new()
	ic_lbl.text = h.icone
	ic_lbl.add_theme_font_size_override("font_size", 24)
	ic_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	ic_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ic_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icone_rect.add_child(ic_lbl)

	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var nome = Label.new()
	nome.text = h.nome
	nome.add_theme_font_size_override("font_size", 16)
	nome.add_theme_color_override("font_color", Color.WHITE)
	info.add_child(nome)

	var pos_row = HBoxContainer.new()
	info.add_child(pos_row)

	var pos = Label.new()
	pos.text = h.posicao
	pos.add_theme_font_size_override("font_size", 12)
	pos.add_theme_color_override("font_color", h.cor)
	pos_row.add_child(pos)

	var dif = Label.new()
	dif.text = "  •  " + h.dificuldade
	dif.add_theme_font_size_override("font_size", 12)
	dif.add_theme_color_override("font_color", Color(0.6,0.7,0.8))
	pos_row.add_child(dif)

	return btn

func _criar_painel_heroi_info() -> Control:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 12)
	return container

func _atualizar_info_heroi() -> void:
	for c in painel_info.get_children():
		c.queue_free()

	var h = HEROIS[heroi_selecionado]

	var desc = Label.new()
	desc.text = h.desc
	desc.add_theme_font_size_override("font_size", 16)
	desc.add_theme_color_override("font_color", Color(0.7,0.8,0.9))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	painel_info.add_child(desc)

	var skills_titulo = Label.new()
	skills_titulo.text = "HABILIDADES"
	skills_titulo.add_theme_font_size_override("font_size", 14)
	skills_titulo.add_theme_color_override("font_color", Color(0.4,0.8,1.0))
	painel_info.add_child(skills_titulo)

	var icones_skill = ["⬛","Q","W","E","R"]
	for i in h.skills.size():
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		painel_info.add_child(row)

		var key = ColorRect.new()
		key.custom_minimum_size = Vector2(36, 36)
		key.color = h.cor * 0.6
		row.add_child(key)

		var key_lbl = Label.new()
		key_lbl.text = icones_skill[i]
		key_lbl.add_theme_font_size_override("font_size", 16)
		key_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		key.add_child(key_lbl)

		var skill_nome = Label.new()
		skill_nome.text = h.skills[i]
		skill_nome.add_theme_font_size_override("font_size", 15)
		skill_nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(skill_nome)

func _criar_painel_runas() -> Control:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 8)

	var titulo = Label.new()
	titulo.text = "RUNA PRINCIPAL"
	titulo.add_theme_font_size_override("font_size", 15)
	titulo.add_theme_color_override("font_color", Color(0.9,0.7,0.2))
	container.add_child(titulo)

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	container.add_child(grid)

	for i in RUNAS.size():
		var r = RUNAS[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 70)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var s = StyleBoxFlat.new()
		s.bg_color = Color(0.1,0.1,0.2)
		s.border_color = r.cor * 0.7
		s.border_width_top = 2
		s.border_width_bottom = 2
		s.border_width_left = 2
		s.border_width_right = 2
		s.corner_radius_top_left = 8
		s.corner_radius_top_right = 8
		s.corner_radius_bottom_left = 8
		s.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", s)

		var vb = VBoxContainer.new()
		vb.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.add_child(vb)

		var nm = Label.new()
		nm.text = r.nome
		nm.add_theme_font_size_override("font_size", 13)
		nm.add_theme_color_override("font_color", r.cor)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(nm)

		var tp = Label.new()
		tp.text = r.tipo
		tp.add_theme_font_size_override("font_size", 11)
		tp.add_theme_color_override("font_color", Color(0.6,0.7,0.8))
		tp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(tp)

		var idx = i
		btn.pressed.connect(func(): runa_selecionada = idx; Console.adicionar_log("[RUNA] %s selecionada" % RUNAS[idx].nome))
		grid.add_child(btn)

	return container

func _criar_painel_poderes() -> Control:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 12)

	var titulo = Label.new()
	titulo.text = "PODERES DE INVOCADOR (escolha 2)"
	titulo.add_theme_font_size_override("font_size", 15)
	titulo.add_theme_color_override("font_color", Color(0.4,0.8,1.0))
	container.add_child(titulo)

	var selecionados = Label.new()
	selecionados.text = "Selecionados: Flash + Smite"
	selecionados.add_theme_font_size_override("font_size", 14)
	selecionados.add_theme_color_override("font_color", Color(0.9,0.7,0.2))
	container.add_child(selecionados)

	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	container.add_child(grid)

	for i in PODERES.size():
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 80)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var s = StyleBoxFlat.new()
		s.bg_color = Color(0.12,0.12,0.25)
		s.border_color = Color(0.3,0.5,0.9,0.6)
		s.border_width_top = 2
		s.border_width_bottom = 2
		s.border_width_left = 2
		s.border_width_right = 2
		s.corner_radius_top_left = 8
		s.corner_radius_top_right = 8
		s.corner_radius_bottom_left = 8
		s.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", s)

		var vb = VBoxContainer.new()
		vb.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.add_child(vb)

		var ic = Label.new()
		ic.text = ICONES_PODERES[i]
		ic.add_theme_font_size_override("font_size", 28)
		ic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(ic)

		var nm = Label.new()
		nm.text = PODERES[i]
		nm.add_theme_font_size_override("font_size", 13)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(nm)

		var idx = i
		btn.pressed.connect(func(): _toggle_poder(idx, selecionados))
		grid.add_child(btn)

	return container

func _toggle_poder(idx: int, label: Label) -> void:
	if poderes_selecionados.has(idx):
		poderes_selecionados.erase(idx)
	elif poderes_selecionados.size() < 2:
		poderes_selecionados.append(idx)
	var nomes = poderes_selecionados.map(func(i): return PODERES[i])
	label.text = "Selecionados: " + " + ".join(nomes)

func _mudar_aba(aba: String) -> void:
	aba_atual = aba
	painel_info.visible = aba == "heroi"
	painel_runas.visible = aba == "runas"
	painel_poderes.visible = aba == "poderes"

func _selecionar_heroi(idx: int) -> void:
	heroi_selecionado = idx
	if heroi_visual:
		heroi_visual.queue_free()
	heroi_visual = _criar_modelo_3d(idx)
	viewport_3d.add_child(heroi_visual)
	_atualizar_info_heroi()
	Console.adicionar_log("[SELEÇÃO] Herói: %s" % HEROIS[idx].nome)

func _confirmar_selecao() -> void:
	var h = HEROIS[heroi_selecionado]
	Boot.heroi_selecionado = h.id
	Boot.runa_selecionada = runa_selecionada
	Boot.poderes_selecionados = poderes_selecionados
	Console.adicionar_log("[SELEÇÃO] Confirmado: %s | Runa: %s" % [h.nome, RUNAS[runa_selecionada].nome])
	get_tree().change_scene_to_file("res://scenes/fila.tscn")
