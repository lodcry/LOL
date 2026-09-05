extends CanvasLayer

const MAX_LOGS = 500
const FILTROS = ["TUDO", "LOG", "ERRO", "WARN"]

var logs: Array = []
var visivel_console: bool = false
var filtro_atual: int = 0
var scroll_pos: float = 0.0

var painel: PanelContainer
var lista: VBoxContainer
var scroll: ScrollContainer
var btn_toggle: Button
var btn_limpar: Button
var filtro_btns: Array = []

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_criar_ui()
	_conectar_logs()
	print("[CONSOLE] VentoryConsole ativo")

func _conectar_logs() -> void:
	Engine.get_main_loop().connect("physics_frame", _checar_erros)

func _checar_erros() -> void:
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_CRASH:
		adicionar_log("💥 CRASH DETECTADO", "error")

func adicionar_log(msg: String, tipo: String = "log") -> void:
	var hora = Time.get_time_string_from_system()
	logs.append({"msg": msg, "tipo": tipo, "hora": hora})
	if logs.size() > MAX_LOGS:
		logs.pop_front()
	_atualizar_lista()

func _criar_ui() -> void:
	btn_toggle = Button.new()
	btn_toggle.text = "⚡ LOG"
	btn_toggle.position = Vector2(get_viewport().get_visible_rect().size.x - 110, 10)
	btn_toggle.size = Vector2(100, 40)
	btn_toggle.pressed.connect(_toggle)
	add_child(btn_toggle)

	painel = PanelContainer.new()
	painel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	painel.size = Vector2(get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y * 0.45)
	painel.visible = false
	add_child(painel)

	var vbox = VBoxContainer.new()
	painel.add_child(vbox)

	var topo = HBoxContainer.new()
	vbox.add_child(topo)

	var titulo = Label.new()
	titulo.text = "⚡ VENTORY CONSOLE"
	topo.add_child(titulo)

	for f in FILTROS:
		var b = Button.new()
		b.text = f
		var idx = filtro_btns.size()
		b.pressed.connect(func(): _set_filtro(idx))
		topo.add_child(b)
		filtro_btns.append(b)

	btn_limpar = Button.new()
	btn_limpar.text = "LIMPAR"
	btn_limpar.pressed.connect(func(): logs.clear(); _atualizar_lista())
	topo.add_child(btn_limpar)

	var btn_fechar = Button.new()
	btn_fechar.text = "✕"
	btn_fechar.pressed.connect(func(): painel.visible = false; visivel_console = false)
	topo.add_child(btn_fechar)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	lista = VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(lista)

func _toggle() -> void:
	visivel_console = !visivel_console
	painel.visible = visivel_console

func _set_filtro(idx: int) -> void:
	filtro_atual = idx
	_atualizar_lista()

func _atualizar_lista() -> void:
	if not lista:
		return
	for c in lista.get_children():
		c.queue_free()
	var filtrados = logs.filter(func(l):
		if filtro_atual == 0: return true
		if filtro_atual == 1: return l.tipo == "log"
		if filtro_atual == 2: return l.tipo == "error"
		if filtro_atual == 3: return l.tipo == "warn"
		return true
	)
	for l in filtrados:
		var lbl = Label.new()
		lbl.text = "[%s] %s" % [l.hora, l.msg]
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		match l.tipo:
			"error": lbl.modulate = Color(1, 0.3, 0.3)
			"warn": lbl.modulate = Color(1, 0.85, 0.2)
			_: lbl.modulate = Color(0.8, 0.9, 1)
		lista.add_child(lbl)
	await get_tree().process_frame
	scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value
