extends Control

var itens_dados: Array = []
var inventario: Node = null
var visivel_loja: bool = false

signal fechou

func _ready() -> void:
	_carregar_itens()
	_criar_ui()
	visible = false

func _carregar_itens() -> void:
	var arquivo = FileAccess.open("res://data/itens.json", FileAccess.READ)
	if arquivo:
		var json = JSON.new()
		json.parse(arquivo.get_as_text())
		var dados = json.get_data()
		if dados and dados.has("itens"):
			itens_dados = dados.itens

func _criar_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04,0.04,0.1,0.95)
	add_child(bg)

	var painel = PanelContainer.new()
	painel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.07,0.07,0.16,0.98)
	s.corner_radius_top_left = 16
	s.corner_radius_top_right = 16
	s.corner_radius_bottom_left = 16
	s.corner_radius_bottom_right = 16
	painel.add_theme_stylebox_override("panel", s)
	add_child(painel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	var mg = MarginContainer.new()
	mg.add_theme_constant_override("margin_left", 24)
	mg.add_theme_constant_override("margin_right", 24)
	mg.add_theme_constant_override("margin_top", 24)
	mg.add_theme_constant_override("margin_bottom", 24)
	painel.add_child(mg)
	mg.add_child(vbox)

	var topo = HBoxContainer.new()
	vbox.add_child(topo)

	var titulo = Label.new()
	titulo.text = "🛒 LOJA"
	titulo.add_theme_font_size_override("font_size", 28)
	titulo.add_theme_color_override("font_color", Color(0.9,0.7,0.2))
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topo.add_child(titulo)

	var btn_fechar = Button.new()
	btn_fechar.text = "✕ FECHAR"
	btn_fechar.custom_minimum_size = Vector2(100, 44)
	btn_fechar.pressed.connect(func(): visible = false; emit_signal("fechou"))
	topo.add_child(btn_fechar)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	for item in itens_dados:
		var card = _criar_card_item(item)
		grid.add_child(card)

func _criar_card_item(item: Dictionary) -> Control:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(140, 100)

	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.1,0.1,0.22)
	s.border_color = Color(0.9,0.7,0.2,0.5)
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_width_left = 1
	s.border_width_right = 1
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 8
	s.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", s)

	var vb = VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.add_child(vb)

	var nome = Label.new()
	nome.text = item.get("nome","?")
	nome.add_theme_font_size_override("font_size", 13)
	nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(nome)

	var custo = Label.new()
	custo.text = "🪙 %d" % item.get("custo", 0)
	custo.add_theme_font_size_override("font_size", 16)
	custo.add_theme_color_override("font_color", Color(0.9,0.7,0.2))
	custo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(custo)

	btn.pressed.connect(func():
		if inventario:
			inventario.comprar(item)
	)
	return btn
