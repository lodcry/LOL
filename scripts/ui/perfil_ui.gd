extends Control

func _ready() -> void:
	Engine.max_fps = 120
	_criar_ui()

func _criar_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.12)
	add_child(bg)

	# Partículas de fundo
	for i in 100:
		var s = ColorRect.new()
		s.size = Vector2(randf_range(1,3), randf_range(1,3))
		s.position = Vector2(randf_range(0,1280), randf_range(0,720))
		s.color = Color(1,1,1,randf_range(0.2,0.6))
		add_child(s)

	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	add_child(hbox)

	# Painel esquerdo — perfil
	var esquerda = _painel_estilo(Color(0.07,0.07,0.15,0.97))
	esquerda.custom_minimum_size = Vector2(320, 0)
	esquerda.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(esquerda)

	var vbox_e = VBoxContainer.new()
	vbox_e.add_theme_constant_override("separation", 24)
	var mg = MarginContainer.new()
	mg.add_theme_constant_override("margin_left", 32)
	mg.add_theme_constant_override("margin_right", 32)
	mg.add_theme_constant_override("margin_top", 40)
	mg.add_theme_constant_override("margin_bottom", 40)
	mg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	esquerda.add_child(mg)
	mg.add_child(vbox_e)

	var avatar = ColorRect.new()
	avatar.custom_minimum_size = Vector2(120, 120)
	avatar.color = Color(0.2, 0.3, 0.7)
	var centro_avatar = CenterContainer.new()
	centro_avatar.add_child(avatar)
	vbox_e.add_child(centro_avatar)

	var icone = Label.new()
	icone.text = "⚡"
	icone.add_theme_font_size_override("font_size", 48)
	icone.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icone.position = Vector2(36, 36)
	avatar.add_child(icone)

	var nome = Label.new()
	nome.text = Boot.nome_jogador
	nome.add_theme_font_size_override("font_size", 28)
	nome.add_theme_color_override("font_color", Color(0.4,0.8,1.0))
	nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox_e.add_child(nome)

	var sep = HSeparator.new()
	vbox_e.add_child(sep)

	for stat in [["🏆 Rank", "Sem classificação"], ["⚔️ Partidas", "0"], ["🎯 KDA", "0/0/0"], ["🌟 Nível", "1"]]:
		var row = HBoxContainer.new()
		var lbl = Label.new()
		lbl.text = stat[0]
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var val = Label.new()
		val.text = stat[1]
		val.add_theme_font_size_override("font_size", 16)
		val.add_theme_color_override("font_color", Color(0.8,0.9,1.0))
		row.add_child(lbl)
		row.add_child(val)
		vbox_e.add_child(row)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_e.add_child(spacer)

	var btn_jogar = _botao("⚔️  JOGAR", Color(0.15,0.4,0.9), 56)
	btn_jogar.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/selecao_heroi.tscn"))
	vbox_e.add_child(btn_jogar)

	var btn_sair = _botao("Sair", Color(0.3,0.1,0.1), 40)
	btn_sair.pressed.connect(func():
		Boot.token = ""
		Boot.nome_jogador = ""
		get_tree().change_scene_to_file("res://scenes/login.tscn")
	)
	vbox_e.add_child(btn_sair)

	# Painel direito — novidades
	var direita = VBoxContainer.new()
	direita.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	direita.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(direita)

	var topo = _painel_estilo(Color(0.06,0.06,0.14,0.95))
	topo.custom_minimum_size = Vector2(0, 200)
	direita.add_child(topo)

	var banner = Label.new()
	banner.text = "⚡ VENTORY\nCampo de batalha te aguarda"
	banner.add_theme_font_size_override("font_size", 32)
	banner.add_theme_color_override("font_color", Color(0.4,0.8,1.0))
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.set_anchors_preset(Control.PRESET_FULL_RECT)
	topo.add_child(banner)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	var mg2 = MarginContainer.new()
	mg2.add_theme_constant_override("margin_left", 16)
	mg2.add_theme_constant_override("margin_right", 16)
	mg2.add_theme_constant_override("margin_top", 16)
	mg2.add_theme_constant_override("margin_bottom", 16)
	mg2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mg2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mg2.add_child(grid)
	direita.add_child(mg2)

	for card in [
		["⚔️", "10 Heróis", "Lee Sin, Jinx, Lux..."],
		["🗺️", "Mapa MOBA", "3 rotas, selva, objetivos"],
		["🛡️", "Sistema de Runas", "Personalize seu estilo"],
		["🤖", "Bots Inteligentes", "5v5 sempre completo"],
	]:
		var c = _painel_estilo(Color(0.1,0.1,0.22,0.9))
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var cv = VBoxContainer.new()
		cv.add_theme_constant_override("separation", 8)
		var cmg = MarginContainer.new()
		cmg.add_theme_constant_override("margin_left", 20)
		cmg.add_theme_constant_override("margin_right", 20)
		cmg.add_theme_constant_override("margin_top", 20)
		cmg.add_theme_constant_override("margin_bottom", 20)
		cmg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cmg.size_flags_vertical = Control.SIZE_EXPAND_FILL
		c.add_child(cmg)
		cmg.add_child(cv)
		var icone_c = Label.new()
		icone_c.text = card[0]
		icone_c.add_theme_font_size_override("font_size", 36)
		cv.add_child(icone_c)
		var titulo_c = Label.new()
		titulo_c.text = card[1]
		titulo_c.add_theme_font_size_override("font_size", 18)
		titulo_c.add_theme_color_override("font_color", Color(0.4,0.8,1.0))
		cv.add_child(titulo_c)
		var desc_c = Label.new()
		desc_c.text = card[2]
		desc_c.add_theme_font_size_override("font_size", 13)
		desc_c.add_theme_color_override("font_color", Color(0.6,0.7,0.8))
		desc_c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(desc_c)
		grid.add_child(c)

func _painel_estilo(cor: Color) -> PanelContainer:
	var p = PanelContainer.new()
	var s = StyleBoxFlat.new()
	s.bg_color = cor
	s.corner_radius_top_left = 12
	s.corner_radius_top_right = 12
	s.corner_radius_bottom_left = 12
	s.corner_radius_bottom_right = 12
	s.border_color = Color(0.3,0.4,0.8,0.5)
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_width_left = 1
	s.border_width_right = 1
	p.add_theme_stylebox_override("panel", s)
	return p

func _botao(texto: String, cor: Color, altura: int) -> Button:
	var b = Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, altura)
	b.add_theme_font_size_override("font_size", 20)
	var s = StyleBoxFlat.new()
	s.bg_color = cor
	s.corner_radius_top_left = 10
	s.corner_radius_top_right = 10
	s.corner_radius_bottom_left = 10
	s.corner_radius_bottom_right = 10
	b.add_theme_stylebox_override("normal", s)
	var sh = s.duplicate()
	sh.bg_color = cor.lightened(0.2)
	b.add_theme_stylebox_override("hover", sh)
	var sp = s.duplicate()
	sp.bg_color = cor.darkened(0.2)
	b.add_theme_stylebox_override("pressed", sp)
	return b
