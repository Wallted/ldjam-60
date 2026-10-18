extends Area2D
class_name Tile


const PATH_SEGMENT = preload("uid://cl1vkv2b6kioq")

var coords: Vector2
var covered: bool 
@onready var label: Label = $Label

var north_path: PathSegment
var west_path: PathSegment


func _ready() -> void:
	label.text = "(%s,%s)" % [coords.x, coords.y]


func add_path_segment(north_not_west: bool, cursor_path: PathSegment = null) -> void:
	var path: PathSegment = PATH_SEGMENT.instantiate() if cursor_path == null else cursor_path
	path.position = Vector2.ZERO
	if north_not_west:
		path.rotation = -0.25*TAU
		assert(north_path == null)
		north_path = path
	else:
		path.rotation = -0.5*TAU
		assert(west_path == null)
		west_path = path
	add_child(path)
	path.update_state(true, cursor_path != null, false)


func remove_path_segment(north_not_west: bool, is_cursor := false) -> void:
	if is_cursor:
		if north_not_west:
			remove_child(north_path)
			assert(north_path != null)
			north_path = null
		else:
			remove_child(west_path)
			assert(west_path != null)
			west_path = null
	else:
		if north_not_west:
			north_path.queue_free()
		else:
			west_path.queue_free()
