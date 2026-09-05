extends Node2D

const LARGURA = 4800
const ALTURA = 4800
const COR_GRAMA = Color(0.13, 0.28, 0.13)
const COR_GRAMA_ESCURA = Color(0.08, 0.18, 0.08)
const COR_ROTA = Color(0.55, 0.45, 0.3)
const COR_RIO = Color(0.1, 0.25, 0.55)
const COR_SELVA = Color(0.06, 0.15, 0.06)
const COR_BASE_AZUL = Color(0.1, 0.2, 0.7)
const COR_BASE_VERMELHA = Color(0.7, 0.1, 0.1)
const COR_TORRE_AZUL = Color(0.3, 0.5, 1.0)
const COR_TORRE_VERMELHA = Color(1.0, 0.3, 0.3)

var torres_azul = []
var torres_vermelho = []
var bases = []

func _ready() -> void:
	_desenhar_mapa()

func _desenhar_mapa() -> void:
	_add_rect(Vector2.ZERO, Vector2(LARGURA, ALTURA), COR_GRAMA)
	_desenhar_selva()
	_desenhar_rotas()
	_desenhar_rio()
	_desenhar_bases()
	_desenhar_torres()
	_desenhar_camps()

func _add_rect(pos: Vector2, tamanho: Vector2, cor: Color, z: int = 0) -> ColorRect:
	var r = ColorRect.new()
	r.position = pos
	r.size = tamanho
	r.color = cor
	r.z_index = z
	add_child(r)
	return r

func _add_circulo(pos: Vector2, raio: float, cor: Color, z: int = 0) -> void:
	var c = ColorRect.new()
	c.position = pos - Vector2(raio, raio)
	c.size = Vector2(raio*2, raio*2)
	c.color = cor
	c.z_index = z
	add_child(c)

func _desenhar_selva() -> void:
	var regioes = [
		[Vector2(800, 800), Vector2(1400, 1000)],
		[Vector2(800, 3000), Vector2(1400, 1000)],
		[Vector2(2600, 800), Vector2(1400, 1000)],
		[Vector2(2600, 3000), Vector2(1400, 1000)],
		[Vector2(1800, 1800), Vector2(1200, 1200)],
	]
	for r in regioes:
		_add_rect(r[0], r[1], COR_SELVA)

func _desenhar_rotas() -> void:
	var espessura = 280
	# bot
	_add_rect(Vector2(300, ALTURA - 300 - espessura), Vector2(LARGURA - 600, espessura), COR_ROTA, 1)
	# top
	_add_rect(Vector2(300, 300), Vector2(LARGURA - 600, espessura), COR_ROTA, 1)
	# mid diagonal
	var pontos_mid = [
		Vector2(300, ALTURA - 600),
		Vector2(300 + espessura, ALTURA - 600),
		Vector2(LARGURA - 600, 300 + espessura),
		Vector2(LARGURA - 600, 300),
		Vector2(LARGURA - 300, 300),
		Vector2(LARGURA - 300 - espessura, 300),
		Vector2(500, ALTURA - 300),
		Vector2(300, ALTURA - 300),
	]
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array(pontos_mid)
	poly.color = COR_ROTA
	poly.z_index = 1
	add_child(poly)

func _desenhar_rio() -> void:
	var rio = Polygon2D.new()
	rio.polygon = PackedVector2Array([
		Vector2(LARGURA/2 - 120, 300),
		Vector2(LARGURA/2 + 120, 300),
		Vector2(LARGURA/2 + 200, ALTURA/2),
		Vector2(LARGURA/2 + 120, ALTURA - 300),
		Vector2(LARGURA/2 - 120, ALTURA - 300),
		Vector2(LARGURA/2 - 200, ALTURA/2),
	])
	rio.color = COR_RIO
	rio.z_index = 1
	add_child(rio)

func _desenhar_bases() -> void:
	_add_circulo(Vector2(400, ALTURA - 400), 300, COR_BASE_AZUL, 2)
	_add_circulo(Vector2(LARGURA - 400, 400), 300, COR_BASE_VERMELHA, 2)

func _desenhar_torres() -> void:
	var pos_azul = [
		# bot
		[Vector2(700, ALTURA-500), Vector2(1400, ALTURA-500), Vector2(2100, ALTURA-500)],
		# top
		[Vector2(700, 500), Vector2(1400, 500), Vector2(2100, 500)],
		# mid
		[Vector2(900, ALTURA-900), Vector2(1600, ALTURA-1600), Vector2(2300, ALTURA-2300)],
	]
	var pos_vermelho = [
		# bot
		[Vector2(LARGURA-700, ALTURA-500), Vector2(LARGURA-1400, ALTURA-500), Vector2(LARGURA-2100, ALTURA-500)],
		# top
		[Vector2(LARGURA-700, 500), Vector2(LARGURA-1400, 500), Vector2(LARGURA-2100, 500)],
		# mid
		[Vector2(LARGURA-900, 900), Vector2(LARGURA-1600, 1600), Vector2(LARGURA-2300, 2300)],
	]
	for lane in pos_azul:
		for pos in lane:
			_desenhar_torre(pos, COR_TORRE_AZUL)
	for lane in pos_vermelho:
		for pos in lane:
			_desenhar_torre(pos, COR_TORRE_VERMELHA)

func _desenhar_torre(pos: Vector2, cor: Color) -> void:
	var base = ColorRect.new()
	base.size = Vector2(60, 60)
	base.position = pos - Vector2(30, 30)
	base.color = cor.darkened(0.3)
	base.z_index = 3
	add_child(base)
	var topo = ColorRect.new()
	topo.size = Vector2(40, 40)
	topo.position = pos - Vector2(20, 20)
	topo.color = cor
	topo.z_index = 4
	add_child(topo)

func _desenhar_camps() -> void:
	var camps = [
		Vector2(1200, 1200), Vector2(1200, 3600),
		Vector2(3600, 1200), Vector2(3600, 3600),
		Vector2(2400, 2400),
		Vector2(1600, 2400), Vector2(3200, 2400),
	]
	for pos in camps:
		_add_circulo(pos, 80, Color(0.5, 0.3, 0.1), 2)
		var label = Label.new()
		label.text = "🐉" if pos == Vector2(2400, 2400) else "🐺"
		label.position = pos - Vector2(20, 20)
		label.z_index = 5
		add_child(label)
