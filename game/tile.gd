extends Area2D
class_name Tile

var coords: Vector2

var _door_orientation: Vector2

@onready
var door: Sprite2D = $Door
@onready
var tile_sprite: Sprite2D = $TileSprite
@onready 
var label: Label = $Label

func _ready() -> void:
	label.text = "(%s,%s)" % [coords.x, coords.y]

func is_door() -> bool:
	return _door_orientation != Vector2.ZERO

func enable_door(_side: Vector2, _orientation: Vector2) -> void:
	door.visible = true
	_door_orientation = _orientation
	door.rotate(PI/2.0 + _orientation.angle())
	door.position = _side * tile_sprite.texture.get_size() / 2.5
