extends Node

const BASE_URL = "https://ventory-worker.daitonaer.workers.dev"

signal login_completo(sucesso: bool, dados: Dictionary)
signal registro_completo(sucesso: bool, dados: Dictionary)
signal erro_rede(mensagem: String)

func login(nome: String, senha: String) -> void:
	print("[NET] Login: %s" % nome)
	var body = JSON.stringify({"nome": nome, "senha": senha})
	_post("/login", body, func(ok, resp):
		var dados = {}
		if ok:
			dados = JSON.parse_string(resp)
			if dados and dados.get("sucesso"):
				Boot.salvar_sessao(dados.token, dados.nome)
				emit_signal("login_completo", true, dados)
				return
		print("[NET] Erro login: %s" % resp)
		emit_signal("login_completo", false, dados)
	)

func registrar(nome: String, senha: String) -> void:
	print("[NET] Registro: %s" % nome)
	var body = JSON.stringify({"nome": nome, "senha": senha})
	_post("/register", body, func(ok, resp):
		var dados = {}
		if ok:
			dados = JSON.parse_string(resp)
			if dados and dados.get("sucesso"):
				Boot.salvar_sessao(dados.token, dados.nome)
				emit_signal("registro_completo", true, dados)
				return
		print("[NET] Erro registro: %s" % resp)
		emit_signal("registro_completo", false, dados)
	)

func _post(rota: String, body: String, callback: Callable) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, code, headers, body_bytes):
		var ok = result == HTTPRequest.RESULT_SUCCESS and code == 200
		var resp = body_bytes.get_string_from_utf8()
		print("[NET] %s → %d | %s" % [rota, code, resp])
		callback.call(ok, resp)
		http.queue_free()
	)
	var headers = ["Content-Type: application/json"]
	if Boot.token != "":
		headers.append("Authorization: Bearer %s" % Boot.token)
	http.request(BASE_URL + rota, headers, HTTPClient.METHOD_POST, body)
