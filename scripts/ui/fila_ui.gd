extends Control

var timer_fila: float = 0.0
const TIMEOUT = 60.0
var jogadores_na_fila: Array = []
var lista_label: Label
var timer_label: Label
var progresso: ColorRect
var _partida_iniciando: bool = false

func _ready() -> void:
	Engine.max_fps = 120
	_criar_ui()
	WS.conectar_fila()
	WS.jogador_atualizado.connect(_on_jogador_fila)
	WS.partida_encontrada.connect(_on_partida_encontrada)
	Console.adicionar_log("[FILA] Procurando partida ranked...")

func _criar_ui() -> void:
	var bg = ColorRect.new(); bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04,0.04,0.1); add_child(bg)
	var centro = CenterContainer.new(); centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)
	var painel = _painel(Color(0.08,0.08,0.18,0.97))
	painel.custom_minimum_size = Vector2(640,440); centro.add_child(painel)
	var vbox = VBoxContainer.new(); vbox.add_theme_constant_override("separation", 20)
	var mg = MarginContainer.new()
	for side in ["left","right","top","bottom"]: mg.add_theme_constant_override("margin_"+side, 40)
	painel.add_child(mg); mg.add_child(vbox)
	var titulo = Label.new(); titulo.text = "🌐 RANKED — PROCURANDO PARTIDA"
	titulo.add_theme_font_size_override("font_size", 22)
	titulo.add_theme_color_override("font_color", Color(0.4,0.8,1.0))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; vbox.add_child(titulo)
	timer_label = Label.new(); timer_label.text = "00:00"
	timer_label.add_theme_font_size_override("font_size", 52)
	timer_label.add_theme_color_override("font_color", Color(0.9,0.7,0.2))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; vbox.add_child(timer_label)
	var prog_bg = ColorRect.new(); prog_bg.custom_minimum_size = Vector2(0,14)
	prog_bg.color = Color(0.1,0.1,0.2); vbox.add_child(prog_bg)
	progresso = ColorRect.new(); progresso.size = Vector2(0,14)
	progresso.color = Color(0.2,0.6,1.0); prog_bg.add_child(progresso)
	var sep = HSeparator.new(); vbox.add_child(sep)
	lista_label = Label.new()
	lista_label.text = "• %s (você)" % Boot.nome_jogador
	lista_label.add_theme_font_size_override("font_size", 16)
	lista_label.add_theme_color_override("font_color", Color(0.3,1.0,0.5))
	vbox.add_child(lista_label)
	var spacer = Control.new(); spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	var aviso = Label.new(); aviso.text = "Após 60s, bots completam o time"
	aviso.add_theme_font_size_override("font_size", 13)
	aviso.add_theme_color_override("font_color", Color(0.5,0.6,0.7))
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; vbox.add_child(aviso)
	var btn = Button.new(); btn.text = "CANCELAR"; btn.custom_minimum_size = Vector2(0,52)
	btn.add_theme_font_size_override("font_size", 18)
	var s = StyleBoxFlat.new(); s.bg_color = Color(0.4,0.1,0.1)
	s.corner_radius_top_left = 10; s.corner_radius_top_right = 10
	s.corner_radius_bottom_left = 10; s.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal", s)
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/perfil.tscn"))
	vbox.add_child(btn)

func _process(delta: float) -> void:
	if _partida_iniciando: return
	timer_fila += delta
	var m = int(timer_fila / 60); var s = int(fmod(timer_fila, 60))
	timer_label.text = "%02d:%02d" % [m, s]
	var pct = min(timer_fila / TIMEOUT, 1.0)
	if progresso.get_parent():
		progresso.size.x = progresso.get_parent().size.x * pct
	if timer_fila >= TIMEOUT and not _partida_iniciando:
		_iniciar_com_bots()

func _on_jogador_fila(id: String, x: float, y: float, nome: String) -> void:
	if nome == Boot.nome_jogador or jogadores_na_fila.has(nome): return
	jogadores_na_fila.append(nome)
	var txt = "• %s (você)\n" % Boot.nome_jogador
	for j in jogadores_na_fila: txt += "• %s\n" % j
	lista_label.text = txt

func _on_partida_encontrada(match_id: String, time: String) -> void:
	if _partida_iniciando: return
	_partida_iniciando = true
	Boot.match_id = match_id; Boot.time_jogador = time
	Console.adicionar_log("[FILA] Partida encontrada! Time: %s" % time)
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/partida.tscn")

func _iniciar_com_bots() -> void:
	_partida_iniciando = true
	Boot.match_id = "ia-" + Boot.nome_jogador
	Boot.time_jogador = "azul"
	Console.adicionar_log("[FILA] Timeout — iniciando com bots")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/partida.tscn")

func _painel(cor: Color) -> PanelContainer:
	var p = PanelContainer.new(); var s = StyleBoxFlat.new()
	s.bg_color = cor
	s.corner_radius_top_left = 16; s.corner_radius_top_right = 16
	s.corner_radius_bottom_left = 16; s.corner_radius_bottom_right = 16
	s.border_color = Color(0.3,0.4,0.8,0.5)
	for side in ["top","bottom","left","right"]: s.set("border_width_"+side, 1)
	p.add_theme_stylebox_override("panel", s); return p
