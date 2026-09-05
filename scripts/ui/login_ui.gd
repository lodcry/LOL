extends Control

@onready var campo_nome: LineEdit = $Painel/VBox/CampoNome
@onready var campo_senha: LineEdit = $Painel/VBox/CampoSenha
@onready var btn_entrar: Button = $Painel/VBox/BtnEntrar
@onready var btn_registrar: Button = $Painel/VBox/BtnRegistrar
@onready var txt_status: Label = $Painel/VBox/Status
@onready var spinner: Control = $Spinner
@onready var painel: PanelContainer = $Painel

var processando: bool = false

func _ready() -> void:
	Engine.max_fps = 120
	campo_senha.secret = true
	btn_entrar.pressed.connect(_on_entrar)
	btn_registrar.pressed.connect(_on_registrar)
	txt_status.text = ""
	spinner.visible = false
	_animacao_entrada()
	Network.login_completo.connect(_on_login_resultado)
	Network.registro_completo.connect(_on_registro_resultado)
	Console.adicionar_log("[LOGIN] Tela iniciada")

func _animacao_entrada() -> void:
	modulate.a = 0.0
	painel.scale = Vector2(0.85, 0.85)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(painel, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK)

func _on_entrar() -> void:
	if processando: return
	var nome = campo_nome.text.strip_edges()
	var senha = campo_senha.text
	if nome.is_empty() or senha.is_empty():
		_set_status("Preencha nome e senha", true)
		return
	_iniciar_carregamento()
	Console.adicionar_log("[LOGIN] Tentando login: %s" % nome)
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
	_iniciar_carregamento()
	Console.adicionar_log("[LOGIN] Registrando: %s" % nome)
	Network.registrar(nome, senha)

func _on_login_resultado(sucesso: bool, dados: Dictionary) -> void:
	_parar_carregamento()
	if sucesso:
		_set_status("Bem-vindo, %s!" % Boot.nome_jogador, false)
		Console.adicionar_log("[LOGIN] ✅ Login OK: %s" % Boot.nome_jogador)
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://scenes/partida.tscn")
	else:
		_set_status("Nome ou senha incorretos", true)
		Console.adicionar_log("[LOGIN] ❌ Falha no login", "error")

func _on_registro_resultado(sucesso: bool, dados: Dictionary) -> void:
	_parar_carregamento()
	if sucesso:
		_set_status("Conta criada! Bem-vindo, %s!" % Boot.nome_jogador, false)
		Console.adicionar_log("[LOGIN] ✅ Registro OK: %s" % Boot.nome_jogador)
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://scenes/partida.tscn")
	else:
		var msg = dados.get("erro", "Erro ao criar conta")
		_set_status(msg, true)
		Console.adicionar_log("[LOGIN] ❌ Falha no registro: %s" % msg, "error")

func _iniciar_carregamento() -> void:
	processando = true
	spinner.visible = true
	btn_entrar.disabled = true
	btn_registrar.disabled = true
	_set_status("Conectando...", false)

func _parar_carregamento() -> void:
	processando = false
	spinner.visible = false
	btn_entrar.disabled = false
	btn_registrar.disabled = false

func _set_status(msg: String, erro: bool) -> void:
	txt_status.text = msg
	txt_status.modulate = Color(1, 0.3, 0.3) if erro else Color(0.3, 1, 0.5)
