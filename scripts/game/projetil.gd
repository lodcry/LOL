extends Node2D

var velocidade: float = 400.0
var dano: float = 50.0
var alvo: Node2D = null
var dono: Node2D = null
var _ativo: bool = true

func configurar(d: float, v: float, a: Node2D, dn: Node2D) -> void:
	dano = d
	velocidade = v
	alvo = a
	dono = dn

func _process(delta: float) -> void:
	if not _ativo or not alvo or not is_instance_valid(alvo):
		queue_free()
		return
	var direcao = (alvo.global_position - global_position).normalized()
	global_position += direcao * velocidade * delta
	if global_position.distance_to(alvo.global_position) < 20:
		_acertar()

func _acertar() -> void:
	_ativo = false
	if alvo and alvo.has_method("receber_dano"):
		alvo.receber_dano(dano)
	queue_free()
