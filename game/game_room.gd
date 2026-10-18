extends Node2D
class_name GameRoom

signal request_focus

@export_group("Grid")
@export
var grid_size : int = 9
@export
var scale_ratio: int
@export
var parent_offset: Vector2
@export
var zoom_level: int
@export
var doors: Array[Door]

@export
var parent_room: GameRoom

var _path_cursor: PathSegment

var _tile_scene = preload("res://game/tile.tscn")
var tile_list: Array[Tile]
var door_list: Array[Tile]
var room_size : Vector2 = Vector2(128.0, 128.0)

@onready 
var grid: Node2D = $Grid
@onready 
var room_area: Area2D = $RoomArea
@onready
var collision_shape_2d: CollisionShape2D = $RoomArea/CollisionShape2D
@onready
var sprite_2d: Sprite2D = $RoomArea/SelectedShader

func _ready() -> void:
	_setup_tiles()
	_setup_doors()
	(collision_shape_2d.shape as RectangleShape2D).size = room_size
	(sprite_2d.texture as PlaceholderTexture2D).size = room_size
	scale = Vector2.ONE * pow(3.0, scale_ratio)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			_try_place_path_segment()


func _setup_tiles() -> void:
	for i in grid_size:
		for j in grid_size:
			var _tile = _tile_scene.instantiate() as Tile
			
			_tile.coords = Vector2(i, j)
			var tile_size = room_size / grid_size
			var _x = (i * tile_size.x) - room_size.x / 2.0
			var _y = (j * tile_size.y) - room_size.y / 2.0
			_tile.position = Vector2(_x, _y) + tile_size / 2.0
			_tile.scale /= grid_size

			_tile.mouse_entered.connect(_on_tile_mouse_entered.bind(_tile))
			_tile.mouse_exited.connect(_on_tile_mouse_exited.bind(_tile))
			_tile.path_hovered_on.connect(_on_path_mouse_entered.bind(_tile))
			_tile.input_event.connect(_on_tile_input_event.bind(_tile))
			_tile.input_pickable = false

			tile_list.append(_tile)
			grid.add_child(_tile)

			j+=1
		i+=1

func _setup_doors() -> void:
	for _door in doors:
		var _tile = get_tile(_door.coord)
		_tile.enable_door(
			Enums.get_direction(_door.side), 
			Enums.get_direction(_door.orientation),
		)
		door_list.append(_tile)

func get_size() -> Vector2:
	return room_size * scale
	
func get_tile(coord: Vector2) -> Tile:
	for _t in tile_list:
		if _t.coords == coord:
			return _t
	return null

func get_neighbour_tiles(coord: Vector2) -> Array[Tile]:
	var neighbours : Array[Tile] = []
	var neigbour_coords = [
		coord + Vector2.UP,
		coord + Vector2.DOWN,
		coord + Vector2.RIGHT,
		coord + Vector2.LEFT,
	]
	for _tile in tile_list:
		if _tile.coords in neigbour_coords:
			neighbours.append(_tile)
			# mock:
			#if _tile.north_path == null:
				#_tile.add_path_segment(true)
			#else:
				#_tile.remove_path_segment(true)
			#if _tile.west_path == null:
				#_tile.add_path_segment(false)
			#else:
				#_tile.remove_path_segment(false)
	return neighbours

func translate_to_parent_tile(_tile: Tile) -> Vector2:
	var parent_base = Vector2(3, 3) + parent_offset
	var res_coord = floor(_tile.coords / 3.0) + parent_base
	return res_coord
	
func disable_room() -> void:
	room_area.input_pickable = false
	for _item in tile_list:
		var _tile : Area2D = _item
		_tile.input_pickable = false

func set_as_pickable() -> void:
	room_area.input_pickable = true

func enable_tiles() -> void:
	for _item in tile_list:
		var _tile : Area2D = _item
		_tile.input_pickable = true

func update_parent() -> void:
	if not parent_room:
		return

	for door_tile in door_list:
		if door_tile.is_source_exit:
			var parent_tile_coords: Vector2 = translate_to_parent_tile(door_tile)
			var follow_tile = parent_room.get_tile(parent_tile_coords + door_tile.door_orientation)
			if follow_tile: 
				follow_tile.has_energy = door_tile.has_energy

		if door_tile.is_source_entry:
			var parent_tile_coords: Vector2 = translate_to_parent_tile(door_tile)
			var follow_tile = parent_room.get_tile(parent_tile_coords - door_tile.door_orientation)
			if follow_tile: 
				door_tile.has_energy = follow_tile.has_energy

func _on_tile_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, tile: Tile) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			tile.has_energy = !tile.has_energy

func _on_tile_mouse_entered(_tile: Tile) -> void:
	pass
	#for _t in tile_list:
		#_t.modulate = Color.WHITE 
	#if _tile:
		#for t in get_neighbour_tiles(_tile.coords):
			#t.modulate = Color.AQUA
		#_tile.modulate = Color.AQUAMARINE

func _on_tile_mouse_exited(_tile: Area2D) -> void:
	pass


func _on_path_mouse_entered(north_not_west: bool, tile: Tile) -> void:
	if tile.input_pickable:
		if _path_cursor != null:
			_path_cursor.set_hovered(false)
		_path_cursor = tile.north_path if north_not_west else tile.west_path
		_path_cursor.set_hovered(true)


func _try_place_path_segment() -> void:
	if _path_cursor != null:
		_path_cursor.set_placed(true)


func _on_room_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			request_focus.emit()

func _on_room_area_mouse_entered() -> void:
	for _t in tile_list:
		_t.modulate = Color.WHITE
	sprite_2d.material.set("shader_parameter/selected",	true);

func _on_room_area_mouse_exited() -> void:
	sprite_2d.material.set("shader_parameter/selected",	false);
	for _t in tile_list:
		_t.modulate = Color.WHITE
