extends Control

const ESCALA = 0.05
const LARGURA_MAPA = 4800
const ALTURA_MAPA = 4800

var jogadores_no_mapa: Dictionary = {}
var camera: Camera2D

func _ready() -> void:
	custom_minimum_size = Vector2(180, 180)
	_desenhar_fundo()

func _desenhar_fundo() -> void:
	var bg = ColorRect.new()
	bg.size = Vector2(180, 180)
	bg.color = Color(0.13, 0.28, 0.13, 0.85)
	add_child(bg)

	var borda = ColorRect.new()
	borda.size = Vector2(180, 180)
	borda.color = Color(0, 0, 0, 0)
	borda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(borda)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 180, 180), Color(0,0,0,0.4))
	draw_rect(Rect2(0, 0, 180, 180), Color(0.3,0.5,1,0.8), false, 2)
	draw_line(Vector2(90, 0), Vector2(90, 180), Color(0.1,0.25,0.55,0.6), 8)
	draw_circle(Vector2(15, 165), 12, Color(0.1, 0.2, 0.7, 0.8))
	draw_circle(Vector2(165, 15), 12, Color(0.7, 0.1, 0.1, 0.8))
	for id in jogadores_no_mapa:
		var pos = jogadores_no_mapa[id]
		var mini_pos = Vector2(pos.x * ESCALA * 180 / LARGURA_MAPA * 20,
			pos.y * ESCALA * 180 / ALTURA_MAPA * 20)
		mini_pos = mini_pos.clamp(Vector2(4,4), Vector2(176,176))
		draw_circle(mini_pos, 5, Color(0.3, 1, 0.5))

func atualizar_jogador(id: String, pos: Vector2) -> void:
	jogadores_no_mapa[id] = pos
