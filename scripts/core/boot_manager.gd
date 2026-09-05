extends Node

const TARGET_FPS = 120
const WORKER_URL = "https://ventory-worker.daitonaer.workers.dev"

var token: String = ""
var nome_jogador: String = ""
var qualidade: int = 1
var heroi_selecionado: String = "lee_sin"
var runa_selecionada: int = 0
var poderes_selecionados: Array = [0, 2]
var time_jogador: String = "azul"
var modo_jogo: String = "ia"
var match_id: String = ""
var ultima_partida: Dictionary = {}

func _ready() -> void:
	Engine.max_fps = TARGET_FPS
	DisplayServer.screen_set_keep_on(true)
	qualidade = int(PlayerData.get_value("qualidade", 1))
	aplicar_qualidade(qualidade)

func aplicar_qualidade(nivel: int) -> void:
	qualidade = nivel
	PlayerData.set_value("qualidade", nivel)
	RenderingServer.set_default_clear_color(Color(0.05, 0.05, 0.1))

func salvar_sessao(t: String, nome: String) -> void:
	token = t
	nome_jogador = nome
	PlayerData.set_value("token", t)
	PlayerData.set_value("nome", nome)

func carregar_sessao() -> bool:
	token = PlayerData.get_value("token", "")
	nome_jogador = PlayerData.get_value("nome", "")
	return token != ""
