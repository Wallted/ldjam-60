extends Node2D
class_name GameRoom

signal request_focus
signal request_rotate
signal path_hover(entered: bool, north_not_west: bool, tile: Tile)

@export
var person_name: Enums.PersonType

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
var parent_room: GameRoom

@export_group("Elements")
@export
var doors: Array[Door]
@export
var gateways: Array[Gateway]

var room_finished: bool

var _tile_scene = preload("res://game/tile.tscn")
var tile_list: Array[Tile]
var room_size : Vector2 = Vector2(128.0, 128.0)
var child_room_list : Array[GameRoom]
var room_area_entered: bool

var door_list: Array[Tile]
var gateway_list: Array[Tile]

@onready
var grid: Node2D = $Grid
@onready
var room_area: Area2D = $RoomArea
@onready
var collision_shape_2d: CollisionShape2D = $RoomArea/CollisionShape2D
@onready
var sprite_2d: Sprite2D = $RoomArea/SelectedShader
@onready
var action_progress: ActionProgress = $"../../CanvasLayer/ActionProgress"

@onready var multi_mesh_instance_2d: MultiMeshInstance2D = $MultiMeshInstance2D

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("rotate") and room_area_entered and not rotating:
		request_rotate.emit()

func _ready() -> void:
	_setup_tiles()
	_setup_doors()
	_setup_gateways()
	(collision_shape_2d.shape as RectangleShape2D).size = room_size
	(sprite_2d.texture as PlaceholderTexture2D).size = room_size
	scale = Vector2.ONE * pow(3.0, scale_ratio)
	if parent_room:
		parent_room.child_room_list.append(self)
	for i in tile_list.size():
		var _tile: Node2D = tile_list[i]
		multi_mesh_instance_2d.multimesh.set_instance_transform_2d(i, _tile.transform)
	z_index = 100 - zoom_level * 10

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

			_tile.path_hover.connect(path_hover.emit.bind(_tile))
			_tile.enabled = false

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

func _setup_gateways() -> void:
	for _gateway in gateways:
		var _tile = get_tile(_gateway.coord)
		_tile.enable_gateway(_gateway)
		gateway_list.append(_tile)

func check_is_room_finished(signal_finished: Signal) -> bool:
	if not room_finished and gateway_list.size() > 0:
		for _gateway in gateway_list:
			if not _gateway.is_tile_powered():
				return false
		signal_finished.emit(self)
		room_finished = true
	return room_finished

func get_size() -> Vector2:
	return room_size * scale

func get_tile(coord: Vector2, in_local_coords := false) -> Tile:
	if in_local_coords:
		for _t in tile_list:
			if _t.local_coords == coord:
				return _t
	else:
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
	update_hover_shader(false)
	room_area_entered = false
	room_area.input_pickable = false
	for _item in tile_list:
		var _tile : Tile = _item
		_tile.enabled = false

func set_as_pickable() -> void:
	room_area.input_pickable = true

	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	var out = space_state.intersect_point(params)
	for resp in out:
		var room : GameRoom = resp['collider'].get_parent() as GameRoom
		if room and room.zoom_level == zoom_level :
			room.update_hover_shader(true)
			room.room_area_entered = true

func enable_tiles() -> void:
	for _item in tile_list:
		var _tile : Tile = _item
		_tile.enabled = true

func update_parent(_disconnect: bool = false) -> void:
	if not parent_room:
		return

	for door_tile in door_list:
		if door_tile.is_source_exit:
			var parent_tile_coords: Vector2 = translate_to_parent_tile(door_tile)
			var follow_tile = parent_room.get_tile(parent_tile_coords + door_tile.door_orientation)
			if follow_tile:
				if _disconnect:
					follow_tile.has_energy = false
					follow_tile.is_source_exit = false
				else:
					follow_tile.has_energy = door_tile.has_energy
					follow_tile.is_source_exit = true

		if door_tile.is_source_entry:
			var parent_tile_coords: Vector2 = translate_to_parent_tile(door_tile)
			var follow_tile = parent_room.get_tile(parent_tile_coords - door_tile.door_orientation)
			if follow_tile:
				if _disconnect:
					door_tile.has_energy = false
					follow_tile.is_source_entry = false
				else:
					door_tile.has_energy = follow_tile.has_energy
					follow_tile.is_source_entry = true

var tween: Tween
var rotating = false
func tween_rotate_room() -> Signal:
	rotating = true
	if tween:
		tween.kill()

	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, 'rotation', rotation + PI / 2.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(action_progress, 'progress', 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(
		func ():
			rotating = false
			reset_parent()
	)

	rotate_room()
	return tween.finished

func reset_parent():
	for child in child_room_list:
		child.reset_parent()
	reparent(%RoomManager.get_parent())

func rotate_room() -> void:
	for child in child_room_list:
		child.parent_offset = Vector2(-child.parent_offset.y, child.parent_offset.x)
		child.reparent(self)
		child.rotate_room()

	update_parent(true)

	for _t in tile_list:
		_t.rotate_tile()
 
func update_hover_shader(selected: bool) -> void:
	sprite_2d.material.set("shader_parameter/selected", selected)
	for _child in child_room_list:
		var _room : GameRoom = _child
		_room.update_hover_shader(selected)

func _on_tile_mouse_entered(_tile: Tile) -> void:
	pass

func _on_tile_mouse_exited(_tile: Area2D) -> void:
	pass

func _on_room_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			request_focus.emit()

func _on_room_area_mouse_entered() -> void:
	room_area_entered = true
	update_hover_shader(true)

func _on_room_area_mouse_exited() -> void:
	room_area_entered = false
	update_hover_shader(false)
