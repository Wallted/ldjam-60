extends Node2D
class_name GameRoom

signal request_focus
signal request_rotate
signal path_hover(entered: bool, north_not_west: bool, tile: Tile)
signal room_powered_changed(person_type: Enums.PersonType, powered: bool)
signal room_area_entered_changed

signal request_unpower_door(source_tile_local_coords: Vector2, room: GameRoom)
signal request_power_door(source_tile_local_coords: Vector2, room: GameRoom)
signal request_door_prune(outside_tile: Tile)

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
@export
var rocks: Array[Rock]

var room_finished: bool
var room_powered: bool:
	set(value):
		if room_powered != value:
			room_powered_changed.emit(person_name, value)
		room_powered = value

var _tile_scene = preload("res://game/tile.tscn")
var tile_list: Array[Tile]
var room_size : Vector2 = Vector2(128.0, 128.0)
var child_room_list : Array[GameRoom]
var room_area_entered: bool

var outside_doors: Dictionary[Tile, Object] # ignore the values, just use keys
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
	_setup_rocks()
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
		)
		# top level door has energy from nowhere
		if parent_room == null:
			_tile.is_flow_tip = true
		door_list.append(_tile)

func _setup_gateways() -> void:
	for _gateway in gateways:
		var _tile = get_tile(_gateway.coord)
		_tile.enable_gateway(_gateway)
		gateway_list.append(_tile)

func _setup_rocks() -> void:
	for _rock in rocks:
		RoomManager._trim_paths_of_neighbors(_rock.coord, self)
		var _tile = get_tile(_rock.coord)
		_tile.enable_rock(_rock)

func check_is_room_finished(signal_finished: Signal) -> bool:
	var _room_powered = room_powered
	if gateway_list.size() > 0:
		_room_powered = true
		for _gateway in gateway_list:
			_room_powered = _room_powered and _gateway.is_tile_powered()

		if not room_finished and _room_powered:
			signal_finished.emit(self)
			room_finished = true
	room_powered = _room_powered
	return room_powered

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

#func get_neighbour_tiles(coord: Vector2) -> Array[Tile]:
	#var neighbours : Array[Tile] = []
	#var neigbour_coords = [
		#coord + Vector2.UP,
		#coord + Vector2.DOWN,
		#coord + Vector2.RIGHT,
		#coord + Vector2.LEFT,
	#]
	#for _tile in tile_list:
		#if _tile.coords in neigbour_coords:
			#neighbours.append(_tile)
	#return neighbours

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

	door_list.sort_custom(func(a: Tile, _b: Tile): return _disconnect != a.is_flow_base)

	for door_tile in door_list:
		var follow_tile := _fetch_outside_door_tile(door_tile)
		if follow_tile:
			if _disconnect:
				if follow_tile.is_flow_base and door_tile.is_flow_tip:
					# todo: direct door-to-door tiles
					request_unpower_door.emit(follow_tile.local_coords, parent_room)
				door_tile.linked_door_tiles.erase(follow_tile)
				follow_tile.linked_door_tiles.erase(door_tile)
				if follow_tile.linked_door_tiles.is_empty():
					parent_room.outside_doors.erase(follow_tile)
					follow_tile.is_outside_door = false
			else:
				request_door_prune.emit(follow_tile)
				door_tile.linked_door_tiles.get_or_add(follow_tile)
				follow_tile.linked_door_tiles.get_or_add(door_tile)
				parent_room.outside_doors.get_or_add(follow_tile)
				follow_tile.is_outside_door = true
				if follow_tile.is_flow_base:
					# todo: direct door-to-door tiles
					follow_tile.is_flow_base = false # gonna be true in a sec down there
					request_power_door.emit(follow_tile.local_coords, parent_room)

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
	
	update_parent(true)
	
	for child in child_room_list:
		child.parent_offset = Vector2(-child.parent_offset.y, child.parent_offset.x)
		child.reparent(self)
		child.rotate_room()

	for _t in tile_list:
		_t.rotate_tile()
 
func update_hover_shader(selected: bool) -> void:
	sprite_2d.material.set("shader_parameter/selected", selected)
	for _child in child_room_list:
		var _room : GameRoom = _child
		_room.update_hover_shader(selected)


func _fetch_outside_door_tile(inside_door_tile: Tile) -> Tile:
	if parent_room == null:
		return null
	var parent_tile_coords: Vector2 = translate_to_parent_tile(inside_door_tile)
	return parent_room.get_tile(parent_tile_coords - inside_door_tile.door_orientation)


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
	room_area_entered_changed.emit()
	update_hover_shader(true)

func _on_room_area_mouse_exited() -> void:
	room_area_entered = false
	update_hover_shader(false)
