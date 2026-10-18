extends Node2D
class_name GameRoom

signal request_focus
signal request_rotate

@export_group("Grid")
@export
var grid_size : int = 9
@export
var scale_ratio: int
@export
var parent_offset: Vector2
@export
var parent_base: Vector2 = Vector2(3, 3)
@export
var zoom_level: int
@export
var doors: Array[Door]

@export
var parent_room: GameRoom

var _tile_scene = preload("res://game/tile.tscn")
var tile_list: Array[Tile]
var door_list: Array[Tile]
var room_size : Vector2 = Vector2(128.0, 128.0)
var child_room_list : Array[GameRoom]

@onready 
var grid: Node2D = $Grid
@onready 
var room_area: Area2D = $RoomArea
@onready
var collision_shape_2d: CollisionShape2D = $RoomArea/CollisionShape2D
@onready
var sprite_2d: Sprite2D = $RoomArea/SelectedShader

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("rotate") and area_entered and not rotating:
		tween_rotate_room()

func _ready() -> void:
	_setup_tiles()
	_setup_doors()
	(collision_shape_2d.shape as RectangleShape2D).size = room_size
	(sprite_2d.texture as PlaceholderTexture2D).size = room_size
	scale = Vector2.ONE * pow(3.0, scale_ratio)
	if parent_room:
		parent_room.child_room_list.append(self)

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
	return neighbours

func translate_to_parent_tile(_tile: Tile, _debug: bool = false) -> Vector2:
	if not parent_room:
		return Vector2.ZERO
	var _parent_base = parent_base + parent_offset
	var res_coord = floor(_tile.coords / pow(3.0, parent_room.scale_ratio - scale_ratio)) + _parent_base
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
				follow_tile.is_source_exit = true

		if door_tile.is_source_entry:
			var parent_tile_coords: Vector2 = translate_to_parent_tile(door_tile)
			var follow_tile = parent_room.get_tile(parent_tile_coords - door_tile.door_orientation)
			if follow_tile: 
				door_tile.has_energy = follow_tile.has_energy
				follow_tile.is_source_entry = true
var tween: Tween
var rotating = false
func tween_rotate_room() -> void:
	rotating = true
	if tween:
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(self, 'rotation', rotation + PI / 2.0, 0.15).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(
		func ():
			rotating = false
			for child in child_room_list:
				child.reparent(get_parent())
	)

	rotate_room()

func rotate_room() -> void:
	for child in child_room_list:
		child.parent_offset = Vector2(-child.parent_offset.y, child.parent_offset.x)
		child.reparent(self)
		child.rotate_room()

	for door_tile in door_list:
		if door_tile.is_source_exit:
			var parent_tile_coords: Vector2 = translate_to_parent_tile(door_tile)
			var follow_tile = parent_room.get_tile(parent_tile_coords + door_tile.door_orientation)
			if follow_tile: 
				follow_tile.has_energy = false
				follow_tile.is_source_exit = false

		if door_tile.is_source_entry:
			var parent_tile_coords: Vector2 = translate_to_parent_tile(door_tile)
			var follow_tile = parent_room.get_tile(parent_tile_coords - door_tile.door_orientation)
			if follow_tile: 
				door_tile.has_energy = false
				follow_tile.is_source_entry = false
	
	for _t in tile_list:
		_t.rotate_tile()
	
func _on_tile_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, tile: Tile) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			tile.has_energy = !tile.has_energy

func _on_tile_mouse_entered(_tile: Tile) -> void:
	for _t in tile_list:
		_t.modulate = Color.WHITE 
	if _tile:
		for t in get_neighbour_tiles(_tile.coords):
			t.modulate = Color.AQUA
		_tile.modulate = Color.AQUAMARINE

func _on_tile_mouse_exited(_tile: Area2D) -> void:
	pass

func _on_room_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			request_focus.emit()

var area_entered: bool
func _on_room_area_mouse_entered() -> void:
	area_entered = true
	for _t in tile_list:
		_t.modulate = Color.WHITE
	sprite_2d.material.set("shader_parameter/selected",	true);

func _on_room_area_mouse_exited() -> void:
	area_entered = false
	sprite_2d.material.set("shader_parameter/selected",	false);
	for _t in tile_list:
		_t.modulate = Color.WHITE
