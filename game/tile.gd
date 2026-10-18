extends Area2D
class_name Tile

var coords: Vector2
var covered: bool 
@onready var label: Label = $Label

func _ready() -> void:
	label.text = "(%s,%s)" % [coords.x, coords.y]
