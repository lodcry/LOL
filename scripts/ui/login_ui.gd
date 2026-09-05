extends Control

var campo_nome: LineEdit
var campo_senha: LineEdit
var btn_entrar: Button
var btn_registrar: Button
var txt_status: Label
var processando: bool = false

func _ready() -> void:
	Engine.max_fps = 120
	_criar_ui()
	Network.login_completo.connect(_on_login_resultado)
	Network.registro_completo.connect(_on_registro_resultado)
	Console.adicionar_log("[LOGIN] Tela iniciada")

func _criar_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.12)
	add_child(bg)

	var estrelas = Node2D.new()
	add_child(estrelas)
	for i in 80:
		var s = ColorRect.new()
		s.size = Vector2(randf_range(1,3), randf_range(1,3))
		s.position = Vector2(randf_range(0,1280), randf_range(0,720))
		s.color = Color(1,1,1, randf_range(0.3,0.9))
		estrelas.add_child(s)

	var centro = CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var painel = PanelContainer.new()
	painel.custom_minimum_size = Vector2(480, 0)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.18, 0.95)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_color = Color(0.3, 0.5, 1.0, 0.6)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	painel.add_theme_stylebox_override("panel", style)
	centro.add_child(painel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.set("theme_override_constants/separation", 20)
	painel.add_child(vbox)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	vbox.add_child(margin)

	var inner = VBoxContainer.new()
	inner.add_theme_constant_override("separation", 20)
	margin.add_child(inner)

	var titulo = Label.new()
	titulo.text = "⚡ VENTORY"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 42)
	titulo.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	inner.add_child(titulo)

	var sub = Label.new()
	sub.text = "Entre no campo de batalha"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color(0.5, 0.5, 0.7))
	inner.add_child(sub)

	var sep = HSeparator.new()
	inner.add_child(sep)

	campo_nome = _criar_campo("👤  Nome do jogador", false)
	inner.add_child(campo_nome)

	campo_senha = _criar_campo("🔒  Senha", true)
	inner.add_child(campo_senha)

	btn_entrar = _criar_botao("ENTRAR", Color(0.2, 0.5, 1.0))
	btn_entrar.pressed.connect(_on_entrar)
	inner.add_child(btn_entrar)

	btn_registrar = _criar_botao("CRIAR CONTA", Color(0.1, 0.35, 0.15))
	btn_registrar.pressed.connect(_on_registrar)
	inner.add_child(btn_registrar)

	txt_status = Label.new()
	txt_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	txt_status.add_theme_font_size_override("font_size", 16)
	txt_status.text = ""
	txt_status.custom_minimum_size = Vector2(0, 30)
	inner.add_child(txt_status)

	painel.scale = Vector2(0.85, 0.85)
	painel.modulate.a = 0.0
	var tw = create_tween().set_parallel(true)
	tw.tween_property(painel, "scale", Vector2(1,1), 0.5).set_trans(Tween.TRANS_BACK)
	tw.tween_property(painel, "modulate:a", 1.0, 0.4)

func _criar_campo(placeholder: String, senha: bool) -> LineEdit:
	var f = LineEdit.new()
	f.placeholder_text = placeholder
	f.secret = senha
	f.custom_minimum_size = Vector2(0, 56)
	f.add_theme_font_size_override("font_size", 20)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.22)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_color = Color(0.3, 0.4, 0.8)
	style.border_width_bottom = 2
	style.content_margin_left = 16
	style.content_margin_right = 16
	f.add_theme_stylebox_override("normal", style)
	return f

func _criar_botao(texto: String, cor: Color) -> Button:
	var b = Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(0, 60)
	b.add_theme_font_size_override("font_size", 22)
	var style = StyleBoxFlat.new()
	style.bg_color = cor
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	b.add_theme_stylebox_override("normal", style)
	var style_hover = style.duplicate()
	style_hover.bg_color = cor.lightened(0.15)
	b.add_theme_stylebox_override("hover", style_hover)
	var style_pressed = style.duplicate()
	style_pressed.bg_color = cor.darkened(0.15)
	b.add_theme_stylebox_override("pressed", style_pressed)
	return b

func _on_entrar() -> void:
	if processando: return
	var nome = campo_nome.text.strip_edges()
	var senha = campo_senha.text
	if nome.is_empty() or senha.is_empty():
		_set_status("Preencha nome e senha", true)
		return
	_iniciar()
	Network.login(nome, senha)

func _on_registrar() -> void:
	if processando: return
	var nome = campo_nome.text.strip_edges()
	var senha = campo_senha.text
	if nome.is_empty() or senha.is_empty():
		_set_status("Preencha nome e senha", true)
		return
	if senha.length() < 4:
		_set_status("Senha precisa ter ao menos 4 caracteres", true)
		return
	_iniciar()
	Network.registrar(nome, senha)

func _on_login_resultado(sucesso: bool, dados: Dictionary) -> void:
	_parar()
	if sucesso:
		_set_status("Bem-vindo, %s!" % Boot.nome_jogador, false)
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://scenes/perfil.tscn")
	else:
		_set_status("Nome ou senha incorretos", true)

func _on_registro_resultado(sucesso: bool, dados: Dictionary) -> void:
	_parar()
	if sucesso:
		_set_status("Conta criada! Bem-vindo, %s!" % Boot.nome_jogador, false)
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://scenes/perfil.tscn")
	else:
		_set_status(dados.get("erro", "Erro ao criar conta"), true)

func _iniciar() -> void:
	processando = true
	btn_entrar.disabled = true
	btn_registrar.disabled = true
	_set_status("Conectando...", false)

func _parar() -> void:
	processando = false
	btn_entrar.disabled = false
	btn_registrar.disabled = false

func _set_status(msg: String, erro: bool) -> void:
	txt_status.text = msg
	txt_status.add_theme_color_override("font_color", Color(1,0.3,0.3) if erro else Color(0.3,1,0.5))
