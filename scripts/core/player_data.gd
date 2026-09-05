extends Node

const SAVE_PATH = "user://ventory_save.cfg"
var config: ConfigFile

func _ready() -> void:
	config = ConfigFile.new()
	config.load(SAVE_PATH)

func get_value(chave: String, padrao = null):
	return config.get_value("dados", chave, padrao)

func set_value(chave: String, valor) -> void:
	config.set_value("dados", chave, valor)
	config.save(SAVE_PATH)
