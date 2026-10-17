extends Node

var frames = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(2):
		frames[str(i)] = [
			load("res://img/placeholder_{}_idle.png".format(i)),
			load("res://img/placeholder_{}_talking_1.png".format(i)),
			load("res://img/placeholder_{}_talking_2.png".format(i)),
		]
