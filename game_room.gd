extends Node2D
class_name GameRoom

@export
var size : Vector2
@export
var doors: Array[Door]
@export
var mock_is_solved: bool

func _ready() -> void:
	for door in doors:
		var _door_txt = Sprite2D.new()
		add_child(_door_txt)
		_door_txt.modulate *= 10.0
		_door_txt.texture = load('res://icon.svg')
		_door_txt.position -= size / 2.0
		_door_txt.position += size / 3.0 * door.coord + size / 6.0
		_door_txt.scale /= 10.0
		_door_txt.position += size / 6.0 * door.side

func is_solved() -> bool:
	return mock_is_solved

func get_size() -> Vector2:
	return size * scale
