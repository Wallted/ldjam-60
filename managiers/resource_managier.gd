extends Node
class_name ResourceManagier

static var RESOURCES: Dictionary[Enums.PersonType, PersonResource] = {
	Enums.PersonType.ARCHAEOLOGIST: preload("uid://bfv5g5akf1qre"),
	Enums.PersonType.CELT: preload("uid://jduf3we633ex"),
	Enums.PersonType.ELON: preload("uid://ceaqardhsnspr"),
	Enums.PersonType.GOLIATH: preload("uid://e0rywutbukxu"),
	Enums.PersonType.ICARUS: preload("uid://7wh55wb1dohc"),
	Enums.PersonType.MICHELANGELO: preload("uid://87f0xxfa8wx5"),
	Enums.PersonType.MONKEY: preload("uid://caj77fkltgd7f"),
	Enums.PersonType.NEANDERTHAL: preload("uid://br7655kp8sprx"),
	Enums.PersonType.SISYPHUS: preload("uid://bv4nytod4j1nt"),
	Enums.PersonType.TOURIST: preload("uid://dt7h14mpkykbb"),
}

static func get_resource(person_type: Enums.PersonType) -> PersonResource:
	return RESOURCES[person_type]


static func get_avatar(person_type: Enums.PersonType) -> Avatar:
	return RESOURCES[person_type].avatar
