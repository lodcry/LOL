extends Node

const WS_URL = "wss://ventory-worker.daitonaer.workers.dev/sala"

signal jogador_atualizado(id: String, x: float, y: float, nome: String)
signal conectado
signal desconectado

var ws: WebSocketPeer
var _conectado: bool = false

func _ready() -> void:
	ws = WebSocketPeer.new()

func conectar_sala() -> void:
	print("[WS] Conectando sala...")
	var headers = ["Authorization: Bearer %s" % Boot.token]
	var err = ws.connect_to_url(WS_URL, TLSOptions.client(), PackedStringArray(headers))
	if err != OK:
		print("[WS] Erro ao conectar: %d" % err)

func _process(_delta: float) -> void:
	if not ws:
		return
	ws.poll()
	var state = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not _conectado:
			_conectado = true
			print("[WS] Conectado!")
			emit_signal("conectado")
			_enviar({"tipo": "entrar", "nome": Boot.nome_jogador})
		while ws.get_available_packet_count() > 0:
			var pkt = ws.get_packet()
			var msg = JSON.parse_string(pkt.get_string_from_utf8())
			if msg and msg.get("tipo") == "estado":
				for j in msg.jogadores:
					emit_signal("jogador_atualizado", j.id, j.x, j.y, j.nome)
	elif state == WebSocketPeer.STATE_CLOSED and _conectado:
		_conectado = false
		print("[WS] Desconectado")
		emit_signal("desconectado")

func enviar_posicao(x: float, y: float) -> void:
	if _conectado:
		_enviar({"tipo": "mover", "x": x, "y": y})

func _enviar(dados: Dictionary) -> void:
	ws.send_text(JSON.stringify(dados))
