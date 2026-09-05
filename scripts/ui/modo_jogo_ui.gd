extends Control

func _ready() -> void:
	Engine.max_fps = 120
	_criar_ui()

func _criar_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04,0.04,0.1)
	add_child(bg)
	var centro = CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 32)
	centro.add_child(vbox)
	var titulo = Label.new()
	titulo.text = "⚔️ SELECIONE O MODO"
	titulo.add_theme_font_size_override("font_size", 32)
	titulo.add_theme_color_override("font_color", Color(0.4,0.8,1.0))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 40)
	vbox.add_child(hbox)
	var btn_ia = _card_modo("🤖", "VS IA", "Partida local com bots\nComeça imediato", Color(0.1,0.3,0.1))
	btn_ia.pressed.connect(func():
		Boot.modo_jogo = "ia"; Boot.match_id = "local-" + Boot.nome_jogador
		get_tree().change_scene_to_file("res://scenes/partida.tscn"))
	hbox.add_child(btn_ia)
	var btn_ranked = _card_modo("🌐", "RANKED", "5v5 online\nAté 60s de espera", Color(0.1,0.15,0.4))
	btn_ranked.pressed.connect(func():
		Boot.modo_jogo = "ranked"
		get_tree().change_scene_to_file("res://scenes/fila.tscn"))
	hbox.add_child(btn_ranked)
	var btn_voltar = Button.new()
	btn_voltar.text = "← Voltar"
	btn_voltar.custom_minimum_size = Vector2(160,44)
	btn_voltar.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/selecao_heroi.tscn"))
	var hb2 = HBoxContainer.new()
	var s1 = Control.new(); s1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s2 = Control.new(); s2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb2.add_child(s1); hb2.add_child(btn_voltar); hb2.add_child(s2)
	vbox.add_child(hb2)

func _card_modo(icone: String, titulo: String, desc: String, cor: Color) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(260,200)
	var s = StyleBoxFlat.new()
	s.bg_color = cor
	s.corner_radius_top_left = 16; s.corner_radius_top_right = 16
	s.corner_radius_bottom_left = 16; s.corner_radius_bottom_right = 16
	s.border_color = Color(0.3,0.5,0.9,0.6)
	s.border_width_top = 2; s.border_width_bottom = 2
	s.border_width_left = 2; s.border_width_right = 2
	btn.add_theme_stylebox_override("normal", s)
	var sh = s.duplicate(); sh.bg_color = cor.lightened(0.15)
	btn.add_theme_stylebox_override("hover", sh)
	var vb = VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 12)
	btn.add_child(vb)
	var ic = Label.new(); ic.text = icone
	ic.add_theme_font_size_override("font_size", 52)
	ic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(ic)
	var tl = Label.new(); tl.text = titulo
	tl.add_theme_font_size_override("font_size", 24)
	tl.add_theme_color_override("font_color", Color.WHITE)
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(tl)
	var dl = Label.new(); dl.text = desc
	dl.add_theme_font_size_override("font_size", 14)
	dl.add_theme_color_override("font_color", Color(0.7,0.8,0.9))
	dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(dl)
	return btn
