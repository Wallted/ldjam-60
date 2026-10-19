extends Node2D
class_name Tile

signal path_hover(entered: bool, north_not_west: bool)

const PATH_SEGMENT = preload("uid://cl1vkv2b6kioq")
const PATH_DOOR: Texture2D = preload("uid://drtfmet3qy7g4")

#@export
#var has_energy: bool
#@export
#var door_texture: Texture2D

var door_sprite: Sprite2D

var coords: Vector2
var local_coords: Vector2
var door_orientation: Vector2

var linked_door_tiles: Dictionary[Tile, Object] # ignore the values, just use keys
var is_inside_door := false
var is_outside_door := false
var is_flow_base := false
var is_flow_tip := false

var north_path: PathSegment
var west_path: PathSegment

var parent_room: GameRoom
var enabled: bool


func _ready() -> void:
	local_coords = coords
	parent_room = get_parent().get_parent()
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
		west_path.is_north_not_west = false
		add_child(west_path)
	if coords.y > 0:
		north_path = PATH_SEGMENT.instantiate()
		north_path.position = Vector2.ZERO
		north_path.rotation = -0.25*TAU
		north_path.mouse_event.connect(path_hover.emit.bind(true))
		north_path.is_north_not_west = true
		add_child(north_path)

func enable_door(_side: Vector2) -> void:
	is_inside_door = true
	var door = Sprite2D.new()
	door.scale *= Vector2(1.0, 30.0/87.0)
	door.texture = PATH_DOOR
	door_orientation = -_side
	door.rotate(PI + door_orientation.angle())
	door.position = _side * Vector2(128, 128)
	door.z_index += 1
	add_child(door)
	door_sprite = door
	set_door_sprite(true, false)

func enable_gateway(_gateway: Gateway) -> void:
	var gateway = Sprite2D.new()
	gateway.scale *= 0.67
	gateway.texture = _gateway.texture
	add_child(gateway)

func enable_rock(_rock: Rock) -> void:
	var rock = Sprite2D.new()
	rock.self_modulate = Color(0.13, 0.092, 0.066, 1.0)
	rock.texture = _rock.texture
	add_child(rock) # todo: switch to multimesh igfuess xfdas
					# xDDD
	
	for _child in get_children():
		if _child is PathSegment:
			_child.queue_free()

func rotate_tile() -> void:
	var offset = Vector2(4.0, 4.0)
	var temp_coord = coords - offset
	var rotated_coord = Vector2(-temp_coord.y, temp_coord.x)
	coords = rotated_coord + offset
	door_orientation = Vector2(-door_orientation.y, door_orientation.x)

func is_tile_powered() -> bool:
	if is_flow_tip:
		return true
	if (north_path != null and north_path.is_powered) or (west_path != null and west_path.is_powered):
		return true
	var south_tile := parent_room.get_tile(local_coords + Vector2.DOWN, true)
	if south_tile != null and south_tile.north_path != null and south_tile.north_path.is_powered:
		return true
	var east_tile := parent_room.get_tile(local_coords + Vector2.RIGHT, true)
	if east_tile != null and east_tile.west_path != null and east_tile.west_path.is_powered:
		return true

	return false


func set_door_sprite(inactive: bool, powered: bool) -> void:
	if inactive:
		door_sprite.self_modulate = Color(0.1, 0.1, 0.1, 0.33)
	elif powered:
		door_sprite.self_modulate = Color("ffffffff")
	else:
		door_sprite.self_modulate = Color("362414ff")
