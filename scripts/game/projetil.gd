extends Node2D

var velocidade: float = 900.0
var dano: float = 50.0
var alvo: Node2D = null
var dono: Node2D = null
var _ativo: bool = true
var _modo: String = "homing"
var _direcao: Vector2 = Vector2.ZERO
var _alcance_max: float = 0.0
var _percorrido: float = 0.0

func configurar(d: float, v: float, a: Node2D, dn: Node2D) -> void:
	dano = d; velocidade = v; alvo = a; dono = dn; _modo = "homing"

func configurar_direcional(d: float, v: float, dir: Vector2, alcance: float, dn: Node2D) -> void:
	dano = d; velocidade = v; _direcao = dir.normalized()
	_alcance_max = alcance; dono = dn; _modo = "direcional"

func _process(delta: float) -> void:
	if not _ativo: queue_free(); return
	if _modo == "direcional":
		global_position += _direcao * velocidade * delta
		_percorrido += velocidade * delta
		if _percorrido >= _alcance_max: queue_free(); return
		var dono_time = dono.get("time_jogador") if dono else ""
		for grupo in ["jogadores", "minions", "bots"]:
			for n in get_tree().get_nodes_in_group(grupo):
				if not is_instance_valid(n) or n == dono: continue
				var n_time = n.get("time_jogador") if n.has_method("get") else ""
				if n_time == dono_time: continue
				if global_position.distance_to(n.global_position) < 45:
					_acertar_node(n); return
	else:
		if not alvo or not is_instance_valid(alvo): queue_free(); return
		global_position += global_position.direction_to(alvo.global_position) * velocidade * delta
		if global_position.distance_to(alvo.global_position) < 25:
			_acertar_node(alvo)

func _acertar_node(n: Node2D) -> void:
	_ativo = false
	if n.has_method("receber_dano_fisico"): n.receber_dano_fisico(dano, dono)
	elif n.has_method("receber_dano"): n.receber_dano(dano)
	queue_free()
