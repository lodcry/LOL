extends Control

signal direcao_mudou(direcao: Vector2)

@export var raio: float = 80.0

var _touch_id: int = -1
var _centro: Vector2
var _cabo: Control
var _direcao: Vector2 = Vector2.ZERO

var direcao: Vector2:
	get: return _direcao

func _ready() -> void:
	_centro = size / 2
	_cabo = $Cabo if has_node("Cabo") else null

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_id == -1:
			if _dentro_do_joystick(event.position):
				_touch_id = event.index
		elif not event.pressed and event.index == _touch_id:
			_touch_id = -1
			_direcao = Vector2.ZERO
			if _cabo: _cabo.position = _centro - _cabo.size / 2
			emit_signal("direcao_mudou", _direcao)
	elif event is InputEventScreenDrag and event.index == _touch_id:
		_atualizar(event.position)

func _atualizar(pos: Vector2) -> void:
	var local = pos - global_position - _centro
	local = local.limit_length(raio)
	_direcao = local / raio
	if _cabo: _cabo.position = _centro + local - _cabo.size / 2
	emit_signal("direcao_mudou", _direcao)

func _dentro_do_joystick(pos: Vector2) -> bool:
	return (pos - global_position - _centro).length() <= raio * 1.5
