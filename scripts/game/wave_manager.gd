extends Node

const INTERVALO_WAVE = 30.0
const MINIONS_POR_WAVE = 6
const MINION_CANNON_WAVE = 3

var _timer: float = 0.0
var numero_wave: int = 0
var ativo: bool = false

const ROTAS_AZUL = {
	"top": [Vector2(400,4400),Vector2(400,2400),Vector2(400,400),Vector2(800,400)],
	"mid": [Vector2(500,4300),Vector2(1500,3000),Vector2(2400,2400),Vector2(3300,1500),Vector2(4300,700)],
	"bot": [Vector2(800,4600),Vector2(2400,4600),Vector2(4400,4600),Vector2(4400,4200)]
}
const ROTAS_VERMELHO = {
	"top": [Vector2(4400,400),Vector2(4400,2400),Vector2(4400,4400),Vector2(4000,4400)],
	"mid": [Vector2(4300,700),Vector2(3300,1500),Vector2(2400,2400),Vector2(1500,3000),Vector2(500,4300)],
	"bot": [Vector2(4000,200),Vector2(2400,200),Vector2(400,200),Vector2(400,600)]
}

signal wave_spawnou(numero)

func _ready() -> void:
	ativo = true
	_timer = INTERVALO_WAVE

func _process(delta: float) -> void:
	if not ativo: return
	_timer -= delta
	if _timer <= 0:
		_timer = INTERVALO_WAVE
		numero_wave += 1
		_spawnar_wave()
		emit_signal("wave_spawnou", numero_wave)

func _spawnar_wave() -> void:
	var is_cannon = numero_wave % MINION_CANNON_WAVE == 0
	for lane in ["top", "mid", "bot"]:
		_spawnar_lane("azul", lane, ROTAS_AZUL[lane], is_cannon)
		_spawnar_lane("vermelho", lane, ROTAS_VERMELHO[lane], is_cannon)

func _spawnar_lane(time: String, lane: String, rota: Array, cannon: bool) -> void:
	if rota.is_empty(): return
	var pos_inicio = rota[0]
	for i in MINIONS_POR_WAVE:
		var ms = load("res://scripts/game/minion.gd")
		var m = CharacterBody2D.new()
		m.set_script(ms)
		m.time = time
		m.time_jogador = time
		m.tipo = "cannon" if (cannon and i == 2) else "caster"
		m.global_position = pos_inicio + Vector2(randf_range(-30,30), randf_range(-30,30))
		m.rota = rota.duplicate()
		m.morreu.connect(_on_minion_morreu)
		get_tree().root.add_child(m)

func _on_minion_morreu(time: String, ouro: int, xp: float, matador: Node2D) -> void:
	if not matador or not is_instance_valid(matador): return
	if matador.has_node("Inventario"):
		matador.get_node("Inventario").ganhar_ouro(ouro)
	if matador.has_node("Heroi"):
		matador.get_node("Heroi").ganhar_xp(xp)
