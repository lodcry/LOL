extends Node

const MAX_SLOTS = 6
var itens: Array = []
var ouro: int = 500

signal item_adicionado(item)
signal ouro_mudou(total)

func comprar(item: Dictionary) -> bool:
	if itens.size() >= MAX_SLOTS:
		Console.adicionar_log("[INV] Inventário cheio!", "warn"); return false
	if ouro < item.get("custo", 0):
		Console.adicionar_log("[INV] Ouro insuficiente!", "warn"); return false
	ouro -= item.get("custo", 0)
	itens.append(item)
	_aplicar_bonus(item)
	emit_signal("item_adicionado", item)
	emit_signal("ouro_mudou", ouro)
	Console.adicionar_log("[INV] Comprou: %s" % item.get("nome","?"))
	return true

func _aplicar_bonus(item: Dictionary) -> void:
	var heroi = get_parent().get_node_or_null("Heroi")
	if not heroi: return
	heroi.ad_bonus += float(item.get("dano_fisico", 0))
	heroi.ap_bonus += float(item.get("poder_magico", 0))
	heroi.armadura += float(item.get("armadura", 0))
	heroi.resistencia_magica += float(item.get("resistencia_magica", 0))
	heroi.hp_max += float(item.get("hp", 0))
	heroi.hp_atual = min(heroi.hp_atual + float(item.get("hp", 0)), heroi.hp_max)
	heroi.velocidade_ataque += float(item.get("velocidade_ataque", 0))

func ganhar_ouro(quantidade: int) -> void:
	ouro += quantidade
	emit_signal("ouro_mudou", ouro)

func get_ouro() -> int:
	return ouro
