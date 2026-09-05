extends Control

var jogadores_na_fila: Array = []
var timer_fila: float = 0.0
var lista_label: Label
var timer_label: Label
var btn_cancelar: Button

func _ready() -> void:
	Engine.max_fps = 120
	_criar_ui()
	WS.conectar_sala()
	WS.jogador_atualizado.connect(_on_jogador_fila)
	Console.adicionar_log("[FILA] Procurando partida...")

func _criar_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04,0.04,0.1)
	add_child(bg)

	var centro = CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var painel = _painel(Color(0.08,0.08,0.18,0.97))
	painel.custom_minimum_size = Vector2(600, 400)
	centro.add_child(painel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	var mg = MarginContainer.new()
	mg.add_theme_constant_override("margin_left", 40)
	mg.add_theme_constant_override("margin_right", 40)
	mg.add_theme_constant_override("margin_top", 40)
	mg.add_theme_constant_override("margin_bottom", 40)
	painel.add_child(mg)
	mg.add_child(vbox)

	var titulo = Label.new()
	titulo.text = "⚔️ PROCURANDO PARTIDA"
	titulo.add_theme_font_size_override("font_size", 28)
	titulo.add_theme_color_override("font_color", Color(0.4,0.8,1.0))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	timer_label = Label.new()
	timer_label.text = "00:00"
	timer_label.add_theme_font_size_override("font_size", 48)
	timer_label.add_theme_color_override("font_color", Color(0.9,0.7,0.2))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(timer_label)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	var jogadores_titulo = Label.new()
	jogadores_titulo.text = "JOGADORES NA FILA"
	jogadores_titulo.add_theme_font_size_override("font_size", 16)
	jogadores_titulo.add_theme_color_override("font_color", Color(0.6,0.7,0.8))
	vbox.add_child(jogadores_titulo)

	lista_label = Label.new()
	lista_label.text = "• %s (você)" % Boot.nome_jogador
	lista_label.add_theme_font_size_override("font_size", 18)
	lista_label.add_theme_color_override("font_color", Color(0.3,1.0,0.5))
	vbox.add_child(lista_label)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	btn_cancelar = Button.new()
	btn_cancelar.text = "CANCELAR"
	btn_cancelar.custom_minimum_size = Vector2(0, 52)
	btn_cancelar.add_theme_font_size_override("font_size", 18)
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.4,0.1,0.1)
	s.corner_radius_top_left = 10
	s.corner_radius_top_right = 10
	s.corner_radius_bottom_left = 10
	s.corner_radius_bottom_right = 10
	btn_cancelar.add_theme_stylebox_override("normal", s)
	btn_cancelar.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/perfil.tscn"))
	vbox.add_child(btn_cancelar)

func _process(delta: float) -> void:
	timer_fila += delta
	var minutos = int(timer_fila / 60)
	var segundos = int(fmod(timer_fila, 60))
	timer_label.text = "%02d:%02d" % [minutos, segundos]

func _on_jogador_fila(id: String, x: float, y: float, nome: String) -> void:
	if not jogadores_na_fila.has(nome) and nome != Boot.nome_jogador:
		jogadores_na_fila.append(nome)
		var texto = "• %s (você)\n" % Boot.nome_jogador
		for j in jogadores_na_fila:
			texto += "• %s\n" % j
		lista_label.text = texto
		Console.adicionar_log("[FILA] %s entrou na fila" % nome)
		if jogadores_na_fila.size() >= 1:
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://scenes/partida.tscn")

func _painel(cor: Color) -> PanelContainer:
	var p = PanelContainer.new()
	var s = StyleBoxFlat.new()
	s.bg_color = cor
	s.corner_radius_top_left = 16
	s.corner_radius_top_right = 16
	s.corner_radius_bottom_left = 16
	s.corner_radius_bottom_right = 16
	s.border_color = Color(0.3,0.4,0.8,0.5)
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_width_left = 1
	s.border_width_right = 1
	p.add_theme_stylebox_override("panel", s)
	return p
