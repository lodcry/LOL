extends Node

var nome: String = ""
var cooldown_max: float = 8.0
var cooldown_atual: float = 0.0
var custo_mana: float = 60.0
var dono: Node2D = null
var pronto: bool = true

signal cooldown_terminou

func _process(delta: float) -> void:
	if not pronto:
		cooldown_atual -= delta
		if cooldown_atual <= 0:
			cooldown_atual = 0.0; pronto = true
			emit_signal("cooldown_terminou")

func usar(alvo_pos: Vector2) -> bool:
	if not pronto: return false
	if dono and dono.has_node("Heroi"):
		if not dono.get_node("Heroi").gastar_mana(custo_mana): return false
	pronto = false
	cooldown_atual = cooldown_max
	return true

func get_cooldown_percent() -> float:
	return cooldown_atual / cooldown_max if not pronto else 0.0
