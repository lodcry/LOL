extends Control

func _ready() -> void:
	Engine.max_fps = 120
	_criar_ui()

func _criar_ui() -> void:
	var dados = Boot.ultima_partida
	var vitoria = dados.get("vitoria", false)
	var duracao = dados.get("duracao", 0)

	var bg = ColorRect.new(); bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04,0.04,0.1); add_child(bg)

	var centro = CenterContainer.new(); centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var vbox = VBoxContainer.new(); vbox.add_theme_constant_override("separation", 28)
	centro.add_child(vbox)

	var titulo = Label.new()
	titulo.text = "🏆 VITÓRIA!" if vitoria else "💀 DERROTA"
	titulo.add_theme_font_size_override("font_size", 52)
	titulo.add_theme_color_override("font_color", Color(0.9,0.7,0.1) if vitoria else Color(0.9,0.3,0.3))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	var mins = duracao / 60; var segs = duracao % 60
	var dur_lbl = Label.new()
	dur_lbl.text = "Duração: %02d:%02d" % [mins, segs]
	dur_lbl.add_theme_font_size_override("font_size", 22)
	dur_lbl.add_theme_color_override("font_color", Color(0.6,0.7,0.8))
	dur_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(dur_lbl)

	var btn_perfil = Button.new(); btn_perfil.text = "🏠 VOLTAR AO PERFIL"
	btn_perfil.custom_minimum_size = Vector2(280,60)
	btn_perfil.add_theme_font_size_override("font_size", 20)
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.15,0.4,0.9)
	s.corner_radius_top_left = 12; s.corner_radius_top_right = 12
	s.corner_radius_bottom_left = 12; s.corner_radius_bottom_right = 12
	btn_perfil.add_theme_stylebox_override("normal", s)
	btn_perfil.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/perfil.tscn"))
	vbox.add_child(btn_perfil)

	var btn_jogar = Button.new(); btn_jogar.text = "⚔️ JOGAR DE NOVO"
	btn_jogar.custom_minimum_size = Vector2(280,60)
	btn_jogar.add_theme_font_size_override("font_size", 20)
	var s2 = StyleBoxFlat.new()
	s2.bg_color = Color(0.1,0.35,0.15)
	s2.corner_radius_top_left = 12; s2.corner_radius_top_right = 12
	s2.corner_radius_bottom_left = 12; s2.corner_radius_bottom_right = 12
	btn_jogar.add_theme_stylebox_override("normal", s2)
	btn_jogar.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/selecao_heroi.tscn"))
	vbox.add_child(btn_jogar)
