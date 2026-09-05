extends Node

var _ameacas: Dictionary = {}

func registrar(entidade: Node2D, ameacador: Node2D, prioridade: int) -> void:
	var id = entidade.get_instance_id()
	if not _ameacas.has(id):
		_ameacas[id] = []
	var lista = _ameacas[id]
	for a in lista:
		if a.node == ameacador:
			a.prioridade = max(a.prioridade, prioridade)
			return
	lista.append({"node": ameacador, "prioridade": prioridade})

func remover(entidade: Node2D, ameacador: Node2D) -> void:
	var id = entidade.get_instance_id()
	if not _ameacas.has(id): return
	_ameacas[id] = _ameacas[id].filter(func(a): return a.node != ameacador)

func get_alvo(entidade: Node2D) -> Node2D:
	var id = entidade.get_instance_id()
	if not _ameacas.has(id): return null
	var lista = _ameacas[id].filter(func(a): return is_instance_valid(a.node))
	_ameacas[id] = lista
	if lista.is_empty(): return null
	lista.sort_custom(func(a, b): return a.prioridade > b.prioridade)
	return lista[0].node

func limpar(entidade: Node2D) -> void:
	_ameacas.erase(entidade.get_instance_id())
