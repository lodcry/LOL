extends Node

func executar(dados: Dictionary, dono: Node2D, alvo_pos: Vector2) -> void:
	match dados.get("tipo", ""):
		"PROJECTILE": _projetil(dados, dono, alvo_pos)
		"AREA": _area(dados, dono, alvo_pos)
		"DASH": _dash(dados, dono, alvo_pos)
		"BUFF": _buff(dados, dono)
		"TARGETED": _targeted(dados, dono, alvo_pos)

func _dano(dados: Dictionary, dono: Node2D) -> float:
	var heroi = dono.get_node_or_null("Heroi")
	var d = float(dados.get("dano", 0))
	if heroi:
		d += heroi.get_ad_total() * float(dados.get("escala_ad", 0))
		d += heroi.get_ap_total() * float(dados.get("escala_ap", 0))
	return d

func _minha_pos(dono: Node2D) -> Vector2:
	return dono._corpo.global_position if dono.get("_corpo") else dono.global_position

func _projetil(dados: Dictionary, dono: Node2D, alvo_pos: Vector2) -> void:
	var d = _dano(dados, dono)
	var vel = float(dados.get("velocidade_projetil", 1400.0))
	var pos = _minha_pos(dono)
	var dir = (alvo_pos - pos).normalized()
	var alcance = float(dados.get("alcance", 900.0))
	var alvo = _buscar_dir(dono, dir, alcance, 180.0)
	var ps = load("res://scripts/game/projetil.gd")
	var p = Node2D.new(); p.set_script(ps); p.global_position = pos
	get_tree().root.add_child(p)
	if alvo: p.configurar(d, vel, alvo, dono)
	else: p.configurar_direcional(d, vel, dir, alcance, dono)

func _area(dados: Dictionary, dono: Node2D, alvo_pos: Vector2) -> void:
	var d = _dano(dados, dono)
	var raio = float(dados.get("raio", 280.0))
	var tipo = dados.get("tipo_dano", "magico")
	var ef = ColorRect.new()
	ef.size = Vector2(raio * 2, raio * 2)
	ef.position = alvo_pos - Vector2(raio, raio)
	ef.color = Color(0.8, 0.3, 0.9, 0.45)
	get_tree().root.add_child(ef)
	for n in _inimigos_raio(dono, alvo_pos, raio):
		if tipo == "fisico" and n.has_method("receber_dano_fisico"): n.receber_dano_fisico(d, dono)
		elif n.has_method("receber_dano_magico"): n.receber_dano_magico(d, dono)
		elif n.has_method("receber_dano"): n.receber_dano(d)
	await get_tree().create_timer(0.35).timeout
	if is_instance_valid(ef): ef.queue_free()

func _dash(dados: Dictionary, dono: Node2D, alvo_pos: Vector2) -> void:
	var pos = _minha_pos(dono)
	var dir = (alvo_pos - pos).normalized()
	var dist = float(dados.get("distancia", 500.0))
	var dest = pos + dir * dist
	var corpo = dono.get("_corpo")
	if corpo:
		var tw = dono.create_tween()
		tw.tween_property(corpo, "position", dest, 0.18)

func _buff(dados: Dictionary, dono: Node2D) -> void:
	var heroi = dono.get_node_or_null("Heroi")
	if not heroi: return
	var dur = float(dados.get("duracao", 3.0))
	match dados.get("efeito", ""):
		"invulnerable":
			heroi.invulneravel = true
			await get_tree().create_timer(dur).timeout
			heroi.invulneravel = false
		"speed":
			var bonus = float(dados.get("bonus_velocidade", 80.0))
			heroi.velocidade_base += bonus
			await get_tree().create_timer(dur).timeout
			heroi.velocidade_base -= bonus
		"heal":
			heroi.curar(_dano(dados, dono))
		"shield":
			heroi.invulneravel = true
			await get_tree().create_timer(min(dur, 2.0)).timeout
			heroi.invulneravel = false

func _targeted(dados: Dictionary, dono: Node2D, alvo_pos: Vector2) -> void:
	var alvo = _buscar_ponto(dono, alvo_pos, 300.0)
	if not alvo: return
	var d = _dano(dados, dono)
	var tipo = dados.get("tipo_dano", "magico")
	if tipo == "fisico" and alvo.has_method("receber_dano_fisico"): alvo.receber_dano_fisico(d, dono)
	elif alvo.has_method("receber_dano_magico"): alvo.receber_dano_magico(d, dono)
	elif alvo.has_method("receber_dano"): alvo.receber_dano(d)

func _buscar_dir(dono: Node2D, dir: Vector2, alcance: float, largura: float) -> Node2D:
	var pos = _minha_pos(dono)
	var dono_time = dono.get("time_jogador")
	var melhor: Node2D = null; var menor = alcance
	for grupo in ["jogadores", "minions", "bots"]:
		for n in get_tree().get_nodes_in_group(grupo):
			if not is_instance_valid(n) or n == dono: continue
			var n_time = n.get("time_jogador") if n.has_method("get") else ""
			if n_time == dono_time: continue
			var v = n.global_position - pos
			var d = v.length()
			if d > alcance: continue
			if abs(dir.angle_to(v.normalized())) < atan2(largura, d) and d < menor:
				menor = d; melhor = n
	return melhor

func _buscar_ponto(dono: Node2D, pos: Vector2, raio: float) -> Node2D:
	var dono_time = dono.get("time_jogador")
	var melhor: Node2D = null; var menor = raio
	for grupo in ["jogadores", "minions"]:
		for n in get_tree().get_nodes_in_group(grupo):
			if not is_instance_valid(n) or n == dono: continue
			var n_time = n.get("time_jogador") if n.has_method("get") else ""
			if n_time == dono_time: continue
			var d = pos.distance_to(n.global_position)
			if d < menor: menor = d; melhor = n
	return melhor

func _inimigos_raio(dono: Node2D, pos: Vector2, raio: float) -> Array:
	var dono_time = dono.get("time_jogador")
	var lista = []
	for grupo in ["jogadores", "minions", "bots"]:
		for n in get_tree().get_nodes_in_group(grupo):
			if not is_instance_valid(n) or n == dono: continue
			var n_time = n.get("time_jogador") if n.has_method("get") else ""
			if n_time == dono_time: continue
			if pos.distance_to(n.global_position) < raio:
				lista.append(n)
	return lista
