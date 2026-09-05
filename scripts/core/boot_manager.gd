extends Node

const TARGET_FPS = 120
const WORKER_URL = "https://ventory-worker.daitonaer.workers.dev"

var token: String = ""
var nome_jogador: String = ""
var qualidade: int = 1

func _ready() -> void:
	Engine.max_fps = TARGET_FPS
	DisplayServer.screen_set_keep_on(true)
	qualidade = int(PlayerData.get_value("qualidade", 1))
	aplicar_qualidade(qualidade)
	print("[BOOT] Ventory iniciado | FPS alvo: %d | Qualidade: %s" % [TARGET_FPS, "Full" if qualidade == 1 else "Leve"])

func aplicar_qualidade(nivel: int) -> void:
	qualidade = nivel
	PlayerData.set_value("qualidade", nivel)
	if nivel == 0:
		RenderingServer.set_default_clear_color(Color(0.05, 0.05, 0.1))
	else:
		RenderingServer.set_default_clear_color(Color(0.08, 0.08, 0.15))

func salvar_sessao(t: String, nome: String) -> void:
	token = t
	nome_jogador = nome
	PlayerData.set_value("token", t)
	PlayerData.set_value("nome", nome)

func carregar_sessao() -> bool:
	token = PlayerData.get_value("token", "")
	nome_jogador = PlayerData.get_value("nome", "")
	return token != ""

var heroi_selecionado: String = "lee_sin"
var runa_selecionada: int = 0
var poderes_selecionados: Array = [0, 2]
