extends Control

var direcao: Vector2 = Vector2.ZERO
var _touch_id: int = -1
var _centro: Vector2 = Vector2.ZERO
var _cabo_pos: Vector2 = Vector2.ZERO
const RAIO = 70.0

func _ready() -> void:
	custom_minimum_size = Vector2(180, 180)
	_centro = Vector2(90, 90)
	_cabo_pos = _centro

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_id == -1:
			var local = event.position - global_position
			if local.distance_to(_centro) <= RAIO * 1.8:
				_touch_id = event.index
		elif not event.pressed and event.index == _touch_id:
			_touch_id = -1
			direcao = Vector2.ZERO
			_cabo_pos = _centro
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == _touch_id:
		var local = event.position - global_position
		var offset = (local - _centro).limit_length(RAIO)
		_cabo_pos = _centro + offset
		direcao = offset / RAIO
		queue_redraw()

func _draw() -> void:
	draw_circle(_centro, RAIO, Color(0.2, 0.3, 0.6, 0.4))
	draw_arc(_centro, RAIO, 0, TAU, 64, Color(0.4, 0.6, 1.0, 0.7), 2)
	draw_circle(_cabo_pos, 30, Color(0.4, 0.6, 1.0, 0.85))
	draw_arc(_cabo_pos, 30, 0, TAU, 32, Color(0.7, 0.85, 1.0, 0.9), 2)
