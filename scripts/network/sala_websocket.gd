extends Node

const BASE_URL = "wss://ventory-worker.daitonaer.workers.dev"

signal jogador_atualizado(id: String, x: float, y: float, nome: String)
signal conectado
signal desconectado
signal partida_encontrada(match_id: String, time: String)

var ws: WebSocketPeer
var _conectado: bool = false
var _modo: String = "sala"

func _ready() -> void:
	ws = WebSocketPeer.new()

func conectar_sala(match_id: String = "") -> void:
	_modo = "sala"
	var url = BASE_URL + "/sala"
	if match_id != "":
		url += "?match=" + match_id
	var headers = PackedStringArray(["Authorization: Bearer %s" % Boot.token])
	var err = ws.connect_to_url(url, TLSOptions.client(), headers)
	if err != OK:
		Console.adicionar_log("[WS] Erro ao conectar sala: %d" % err, "error")

func conectar_fila() -> void:
	_modo = "fila"
	ws = WebSocketPeer.new()
	var url = BASE_URL + "/fila"
	var headers = PackedStringArray(["Authorization: Bearer %s" % Boot.token])
	ws.connect_to_url(url, TLSOptions.client(), headers)

func _process(_delta: float) -> void:
	if not ws: return
	ws.poll()
	var state = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not _conectado:
			_conectado = true
			emit_signal("conectado")
			if _modo == "sala":
				_enviar({"tipo": "entrar", "nome": Boot.nome_jogador, "heroi": Boot.heroi_selecionado, "time": Boot.time_jogador})
			elif _modo == "fila":
				_enviar({"tipo": "entrar_fila", "nome": Boot.nome_jogador, "heroi": Boot.heroi_selecionado})
		while ws.get_available_packet_count() > 0:
			var pkt = ws.get_packet()
			var msg = JSON.parse_string(pkt.get_string_from_utf8())
			if not msg: continue
			match msg.get("tipo"):
				"estado":
					for j in msg.get("jogadores", []):
						emit_signal("jogador_atualizado", j.id, j.x, j.y, j.nome)
				"partida_encontrada":
					emit_signal("partida_encontrada", msg.get("match_id",""), msg.get("time","azul"))
	elif state == WebSocketPeer.STATE_CLOSED and _conectado:
		_conectado = false
		emit_signal("desconectado")

func enviar_posicao(x: float, y: float) -> void:
	if _conectado:
		_enviar({"tipo": "mover", "x": x, "y": y})

func _enviar(dados: Dictionary) -> void:
	if ws and ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.send_text(JSON.stringify(dados))
