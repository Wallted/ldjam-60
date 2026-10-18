extends Area2D
class_name Tile


signal path_hover(entered: bool, north_not_west: bool)

const PATH_SEGMENT = preload("uid://cl1vkv2b6kioq")

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

var north_path: PathSegment
var west_path: PathSegment


func _ready() -> void:
	label.text = "(%s,%s)" % [coords.x, coords.y]
	_init_path_segments()


func remove_path(north_not_west: bool):
	if north_not_west:
		if north_path != null:
			north_path.queue_free()
	elif west_path != null:
		west_path.queue_free()


func _init_path_segments() -> void:
	if coords.x > 0:
		west_path = PATH_SEGMENT.instantiate()
		west_path.position = Vector2.ZERO
		west_path.rotation = -0.5*TAU
		west_path.mouse_event.connect(path_hover.emit.bind(false))
		add_child(west_path)
	if coords.y > 0:
		north_path = PATH_SEGMENT.instantiate()
		north_path.position = Vector2.ZERO
		north_path.rotation = -0.25*TAU
		north_path.mouse_event.connect(path_hover.emit.bind(true))
		add_child(north_path)

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
