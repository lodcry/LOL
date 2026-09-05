extends Node

const BASE_URL = "https://ventory-worker.daitonaer.workers.dev"

signal login_completo(sucesso: bool, dados: Dictionary)
signal registro_completo(sucesso: bool, dados: Dictionary)
signal perfil_carregado(dados: Dictionary)

func login(nome: String, senha: String) -> void:
	_post("/login", JSON.stringify({"nome": nome, "senha": senha}), func(ok, resp):
		var dados = {}
		if ok:
			dados = JSON.parse_string(resp)
			if dados and dados.get("sucesso"):
				Boot.salvar_sessao(dados.token, dados.nome)
				emit_signal("login_completo", true, dados)
				return
		emit_signal("login_completo", false, dados)
	)

func registrar(nome: String, senha: String) -> void:
	_post("/register", JSON.stringify({"nome": nome, "senha": senha}), func(ok, resp):
		var dados = {}
		if ok:
			dados = JSON.parse_string(resp)
			if dados and dados.get("sucesso"):
				Boot.salvar_sessao(dados.token, dados.nome)
				emit_signal("registro_completo", true, dados)
				return
		emit_signal("registro_completo", false, dados)
	)

func buscar_perfil() -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, code, _h, body):
		var dados = JSON.parse_string(body.get_string_from_utf8())
		if dados and dados.get("sucesso"):
			emit_signal("perfil_carregado", dados)
		http.queue_free()
	)
	http.request(BASE_URL + "/perfil", ["Authorization: Bearer %s" % Boot.token], HTTPClient.METHOD_GET)

func _post(rota: String, body: String, callback: Callable) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, code, _h, body_bytes):
		var ok = result == HTTPRequest.RESULT_SUCCESS and code == 200
		var resp = body_bytes.get_string_from_utf8()
		callback.call(ok, resp)
		http.queue_free()
	)
	var headers = ["Content-Type: application/json"]
	if Boot.token != "":
		headers.append("Authorization: Bearer %s" % Boot.token)
	http.request(BASE_URL + rota, headers, HTTPClient.METHOD_POST, body)
