extends Node

const MAX_SLOTS = 6
var itens: Array = []
var ouro: int = 500

signal item_adicionado(item)
signal item_removido(idx)
signal ouro_mudou(total)

func comprar(item: Dictionary) -> bool:
	if itens.size() >= MAX_SLOTS:
		Console.adicionar_log("[INV] Inventário cheio!", "warn")
		return false
	var custo = item.get("custo", 0)
	if ouro < custo:
		Console.adicionar_log("[INV] Ouro insuficiente! Precisa %d tem %d" % [custo, ouro], "warn")
		return false
	ouro -= custo
	itens.append(item)
	emit_signal("item_adicionado", item)
	emit_signal("ouro_mudou", ouro)
	Console.adicionar_log("[INV] Comprou: %s por %d ouro" % [item.nome, custo])
	return true

func vender(idx: int) -> void:
	if idx >= itens.size(): return
	var item = itens[idx]
	var retorno = int(item.get("custo", 0) * 0.7)
	ouro += retorno
	itens.remove_at(idx)
	emit_signal("item_removido", idx)
	emit_signal("ouro_mudou", ouro)
	Console.adicionar_log("[INV] Vendeu: %s por %d ouro" % [item.nome, retorno])

func ganhar_ouro(quantidade: int) -> void:
	ouro += quantidade
	emit_signal("ouro_mudou", ouro)

func get_bonus_dano() -> float:
	var total = 0.0
	for item in itens:
		total += item.get("dano_fisico", 0)
		total += item.get("poder_magico", 0)
	return total

func get_bonus_hp() -> float:
	var total = 0.0
	for item in itens:
		total += item.get("hp", 0)
	return total
