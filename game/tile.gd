extends Area2D
class_name Tile

var coords: Vector2
var door_orientation: Vector2

@export
var has_energy: bool

var is_source_exit: bool
var is_source_entry: bool

@onready
var door: Sprite2D = $Door
@onready
var tile_sprite: Sprite2D = $TileSprite
@onready 
var label: Label = $Label

func _process(_delta: float) -> void:
	if has_energy:
		door.modulate = Color.GREEN
		modulate = Color.GREEN
	else:
		door.modulate = Color.WHITE
		modulate = Color.WHITE

func _ready() -> void:
	label.text = "(%s,%s)" % [coords.x, coords.y]
	
func is_door() -> bool:
	return door_orientation != Vector2.ZERO

func enable_door(_side: Vector2, _orientation: Vector2) -> void:
	door.visible = true
	door_orientation = _orientation
	door.rotate(PI/2.0 + _orientation.angle())
	door.position = _side * tile_sprite.texture.get_size() / 2.5

	var _follow_tile = coords + door_orientation
	is_source_exit = _follow_tile != _follow_tile.clamp(Vector2.ZERO, Vector2(8.0, 8.0))

	_follow_tile = coords - door_orientation
	is_source_entry = _follow_tile != clamp(_follow_tile, Vector2.ZERO, Vector2(8.0, 8.0))
