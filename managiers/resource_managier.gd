extends Node
class_name ResourceManagier

static var RESOURCES: Dictionary[String, PersonResource] = {
	'archaeologist': preload("uid://bfv5g5akf1qre"),
	'celt': preload("uid://jduf3we633ex"),
	'elon': preload("uid://ceaqardhsnspr"),
	'goliath': preload("uid://e0rywutbukxu"),
	'icarus': preload("uid://7wh55wb1dohc"),
	'michelangelo': preload("uid://87f0xxfa8wx5"),
	'monkey': preload("uid://caj77fkltgd7f"),
	'neanderthal': preload("uid://br7655kp8sprx"),
	'sisyphus': preload("uid://bv4nytod4j1nt"),
	'tourist': preload("uid://dt7h14mpkykbb"),
}


static func get_resource(name: String) -> PersonResource:
	return RESOURCES[name]


static func get_avatar(name: String) -> Avatar:
	return RESOURCES[name].avatar
