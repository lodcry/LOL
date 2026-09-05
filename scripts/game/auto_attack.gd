extends Node

var _player: Node2D = null
var _heroi: Node = null
var _timer: float = 0.0
var ativo: bool = true

func _ready() -> void:
	_player = get_parent()
	_heroi = _player.get_node_or_null("Heroi")

func _process(delta: float) -> void:
	if not ativo: return
	if not _heroi or not _heroi.vivo: return
	_timer += delta
	var intervalo = 1.0 / _heroi.velocidade_ataque
	if _timer >= intervalo:
		_timer = 0.0
		_executar()

func _executar() -> void:
	var alvo = Aggro.get_alvo(_player)
	if not alvo or not is_instance_valid(alvo): return
	var minha_pos = _player._corpo.global_position if _player.get("_corpo") else _player.global_position
	var dist = minha_pos.distance_to(alvo.global_position)
	if dist > _heroi.alcance_ataque * 1.2: return
	var dano = _heroi.get_ad_total()
	if _heroi.alcance_ataque <= 200:
		if alvo.has_method("receber_dano_fisico"):
			alvo.receber_dano_fisico(dano, _player)
		elif alvo.has_method("receber_dano"):
			alvo.receber_dano(dano)
		if _heroi.red_buff:
			_aplicar_dot(alvo, dano * 0.1, 3.0)
			if alvo.has_method("aplicar_slow"):
				alvo.aplicar_slow(0.2, 3.0)
	else:
		_spawnar_projetil(alvo, dano)

func _spawnar_projetil(alvo: Node2D, dano: float) -> void:
	var minha_pos = _player._corpo.global_position if _player.get("_corpo") else _player.global_position
	var ps = load("res://scripts/game/projetil.gd")
	var p = Node2D.new()
	p.set_script(ps)
	p.global_position = minha_pos
	get_tree().root.add_child(p)
	p.configurar(dano, 900.0, alvo, _player)

func _aplicar_dot(alvo: Node2D, dano_tick: float, duracao: float) -> void:
	var ticks = int(duracao / 0.5)
	for _i in ticks:
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(alvo) and alvo.has_method("receber_dano_fisico"):
			alvo.receber_dano_fisico(dano_tick, _player)
