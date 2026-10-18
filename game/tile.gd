extends Area2D
class_name Tile


signal path_hovered_on(north_not_west: bool)

const PATH_SEGMENT = preload("uid://cl1vkv2b6kioq")

var coords: Vector2
var covered: bool 
@onready var label: Label = $Label

var north_path: PathSegment
var west_path: PathSegment


func _ready() -> void:
	label.text = "(%s,%s)" % [coords.x, coords.y]
	_init_path_segments()


func _init_path_segments() -> void:
	if coords.x > 0:
		west_path = PATH_SEGMENT.instantiate()
		west_path.position = Vector2.ZERO
		west_path.rotation = -0.5*TAU
		west_path.mouse_entered.connect(path_hovered_on.emit.bind(false))
		add_child(west_path)
	if coords.y > 0:
		north_path = PATH_SEGMENT.instantiate()
		north_path.position = Vector2.ZERO
		north_path.rotation = -0.25*TAU
		north_path.mouse_entered.connect(path_hovered_on.emit.bind(true))
		add_child(north_path)
