extends Node2D

var hp_max: float = 5500.0
var hp_atual: float = 5500.0
var time: String = "azul"
var time_jogador: String = "azul"
var destruido: bool = false

signal destruido_sinal(perdedor)

func _ready() -> void:
	time_jogador = time
	add_to_group("nexus")
	var sprite = ColorRect.new()
	sprite.size = Vector2(100, 100)
	sprite.position = Vector2(-50, -50)
	sprite.color = Color(0.2,0.4,1.0) if time == "azul" else Color(1.0,0.2,0.2)
	add_child(sprite)
	var lbl = Label.new()
	lbl.text = "NEXUS"
	lbl.position = Vector2(-28, -10)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	add_child(lbl)

func receber_dano(d: float) -> void:
	receber_dano_fisico(d)

func receber_dano_fisico(d: float, _fonte: Node2D = null) -> void:
	if destruido: return
	hp_atual = max(0, hp_atual - d)
	Console.adicionar_log("[NEXUS] HP %s: %.0f/%.0f" % [time, hp_atual, hp_max])
	if hp_atual <= 0: _destruir()

func _destruir() -> void:
	destruido = true
	emit_signal("destruido_sinal", time)
	Console.adicionar_log("🏆 Nexus %s destruído!" % time)
