extends Node

var nome: String = ""
var descricao: String = ""
var cooldown_max: float = 8.0
var cooldown_atual: float = 0.0
var custo_mana: float = 60.0
var dano_base: float = 100.0
var alcance: float = 600.0
var dono: Node2D = null
var pronto: bool = true

signal usou(skill)
signal cooldown_terminou

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if not pronto:
		cooldown_atual -= delta
		if cooldown_atual <= 0:
			cooldown_atual = 0.0
			pronto = true
			emit_signal("cooldown_terminou")

func usar(alvo_pos: Vector2) -> bool:
	if not pronto: return false
	if dono and dono.has_method("gastar_mana"):
		if not dono.gastar_mana(custo_mana): return false
	pronto = false
	cooldown_atual = cooldown_max
	_executar(alvo_pos)
	emit_signal("usou", self)
	Console.adicionar_log("[SKILL] %s usou %s" % [dono.nome if dono else "?", nome])
	return true

func _executar(alvo_pos: Vector2) -> void:
	pass

func get_cooldown_percent() -> float:
	return cooldown_atual / cooldown_max if not pronto else 0.0
