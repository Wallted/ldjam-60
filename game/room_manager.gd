extends Node2D
class_name RoomManager

signal level_changed(person_type: Enums.PersonType)
signal room_finished(room: GameRoom)
signal room_powered_changed(person_type: Enums.PersonType, powered: bool)

# audio
signal placed_powered_path
signal placed_unpowered_path
signal unplace_path
signal rotate_room
signal zoom_in_room
signal zoom_out_room

var room_list : Array[GameRoom]
var currently_focused_room: GameRoom

@onready
var camera_2d: RoomCamera = $"../Camera2D"

var _path_cursor: PathSegment
var _path_cursor_north_not_west: bool

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and GameState.state == GameState.State.ACTION_FREE:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.pressed:
			if currently_focused_room.room_unlocked:
				focus_on_room_action(currently_focused_room.parent_room)
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			_try_place_path_segment()
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			_try_unplace_path_segment()

func _ready() -> void:
	for _child in get_parent().get_children():
		if _child is GameRoom:
			await _child.ready
			room_list.append(_child)

			var _room : GameRoom = _child
			_room.request_focus.connect(_on_focus_request.bind(_room))
			_room.request_rotate.connect(_on_rotate_request.bind(_room))
			_room.path_hover.connect(_on_path_mouse_event)
			_room.request_unpower_door.connect(_try_unpower_a_door)
			_room.request_power_door.connect(_try_power_a_door)
			_room.request_door_prune.connect(_door_prune)
			_room.room_powered_changed.connect(_on_room_power_changed)
			_room.room_area_entered_changed.connect(func (): hide_cursor())

	_snap_rooms_together()
	room_list.reverse()
	
	GameState.set_state(GameState.State.ACTION_FREE)

	focus_on_room_action(room_list[0], false)

	for room in room_list:
		room.update_parent()


func _on_room_power_changed(person_type: Enums.PersonType, powered: bool) -> void:
	room_powered_changed.emit(person_type, powered)


func _process(_delta: float) -> void:
	currently_focused_room.check_is_room_unlocked()
	for room in room_list:
		room.check_is_room_finished(room_finished)

func _snap_rooms_together() -> void: # todo: horrendous, fix it
	var dict : Dictionary[int, Array]
	for room in room_list:
		if room.zoom_level not in dict.keys():
			dict.set(room.zoom_level, [])
		dict[room.zoom_level].append(room)

		var _tiles_to_remove: Array[Vector2] = []
		for _t in room.tile_list:
			var local_coord = room.translate_to_parent_tile(_t)
			if local_coord:
				_tiles_to_remove.append(local_coord)

		for _t in _tiles_to_remove:
			if room.parent_room:
				_remove_tile(_t, room.parent_room)

	var prev_tile_size: Vector2 = Vector2.ZERO
	var prev_position: Vector2 = Vector2.ZERO
	for key in dict.keys():
		var r_l = dict[key]

		for room in r_l:
			room.position = prev_position
			room.position += room.parent_offset * prev_tile_size

		prev_tile_size = r_l[0].room_size / r_l[0].grid_size * r_l[0].scale
		prev_position = r_l[0].position

func finish_room() -> void:
	room_finished.emit(currently_focused_room)

func rotate_room_action(room) -> void:
	rotate_room.emit()
	if not GameState.is_state(GameState.State.ACTION_FREE):
		return

	GameState.set_state(GameState.State.ACTION_PENDING)
	room.tween_rotate_room().connect(_finish_rotation_updates.bind(room))


func _finish_rotation_updates(room: GameRoom) -> void:
	GameState.set_state(GameState.State.ACTION_FREE)
	room.update_parent()


func focus_on_room_action(target_room: GameRoom, tween: bool = true):
	if currently_focused_room != null and target_room != null:
		if target_room.zoom_level > currently_focused_room.zoom_level:
			zoom_out_room.emit()
		else:
			zoom_in_room.emit()
	
	if not GameState.is_state(GameState.State.ACTION_FREE):
		return

	if not target_room:
		return

	currently_focused_room = target_room

	for room in room_list:
		room.disable_room()

	hide_cursor()
	
	if not tween:
		camera_2d.zoom_room(room_list[0])
		target_room.enable_tiles()
	else:
		camera_2d.tween_zoom_room(target_room).connect(_on_zoom_finished.bind(target_room))
		GameState.set_state(GameState.State.ACTION_PENDING)

func hide_cursor() -> void:
	if _path_cursor != null:
		_path_cursor.set_hovered(false)
	_path_cursor = null

func _on_focus_request(room: GameRoom) -> void:
	focus_on_room_action(room)

func _on_rotate_request(room: GameRoom) -> void:
	rotate_room_action(room)

func _on_zoom_finished(target_room: GameRoom) -> void:
	GameState.set_state(GameState.State.ACTION_FREE)
	for room in room_list:
		if room.zoom_level == target_room.zoom_level - 1:
			room.set_as_pickable()
	target_room.enable_tiles()
	level_changed.emit(target_room.person_name)

func _on_path_mouse_event(entered: bool, north_not_west: bool, tile: Tile) -> void:
	if tile.enabled:
		if entered == false: # no lepiej tak działa lol
			return
		if _path_cursor != null:
			_path_cursor.set_hovered(false)
		if entered:
			_path_cursor = tile.north_path if north_not_west else tile.west_path
			_path_cursor_north_not_west = north_not_west
			var is_eligible_to_hover := true
			if not _path_cursor.is_placed:
				var target_tile_coords: Vector2 = _path_cursor.get_parent().local_coords + (Vector2.UP if _path_cursor_north_not_west else Vector2.LEFT)
				is_eligible_to_hover = _tile_placed_paths_count(_path_cursor.get_parent().local_coords, currently_focused_room) < 2
				is_eligible_to_hover = is_eligible_to_hover and _tile_placed_paths_count(target_tile_coords, currently_focused_room) < 2
			if is_eligible_to_hover:
				_path_cursor.set_hovered(true)


func _try_place_path_segment() -> void:
	if _path_cursor != null and _path_cursor.is_hovered and not _path_cursor.is_placed:
		_path_cursor.set_placed(true)
		var parent_tile: Tile = _path_cursor.get_parent()
		var neighbor_tile := parent_tile.parent_room.get_tile(parent_tile.local_coords + (Vector2.UP if _path_cursor.is_north_not_west else Vector2.LEFT), true)
		var front_endpoint := _get_segment_endpoint(_path_cursor, false)
		var back_endpoint := _get_segment_endpoint(_path_cursor, true)
		assert(neighbor_tile != null)
		# there is max one powered endpoint
		assert(not parent_tile.is_flow_tip or not neighbor_tile.is_flow_tip or front_endpoint == null or not front_endpoint.is_powered or back_endpoint == null or not back_endpoint.is_powered)
		if parent_tile.is_flow_tip or (back_endpoint != null and back_endpoint.is_powered):
			_power_a_segment(_path_cursor, parent_tile.local_coords)
			placed_powered_path.emit()
		elif neighbor_tile.is_flow_tip or(front_endpoint != null and front_endpoint.is_powered):
			_power_a_segment(_path_cursor, _path_segment_tip_local_coords(_path_cursor))
			placed_powered_path.emit()
		else:
			placed_unpowered_path.emit()


func _try_unplace_path_segment() -> void:
	if _path_cursor != null:
		_unpower_a_segment(_path_cursor)
		_path_cursor.has_backward_flow = false
		_path_cursor.set_placed(false)
		unplace_path.emit()


func _remove_tile(tile_coords: Vector2, room: GameRoom) -> void:
	var tile := room.get_tile(tile_coords)
	if tile != null:
		room.tile_list.erase(tile)
		tile.queue_free()
		_trim_paths_of_neighbors(tile.local_coords, room)


static func _trim_paths_of_neighbors(unavailable_tile_local_coords: Vector2, room: GameRoom) -> void:
	var south_tile := room.get_tile(unavailable_tile_local_coords + Vector2.DOWN, true)
	var east_tile := room.get_tile(unavailable_tile_local_coords + Vector2.RIGHT, true)
	if south_tile != null:
		south_tile.remove_path(true)
	if east_tile != null:
		east_tile.remove_path(false)


func _tile_placed_paths_count(tile_local_coords: Vector2, room: GameRoom) -> int:
	var result := 0
	var tile := room.get_tile(tile_local_coords, true)
	if tile != null:
		if tile.north_path != null and tile.north_path.is_placed:
			result += 1
		if tile.west_path != null and tile.west_path.is_placed:
			result += 1
	var south_tile := room.get_tile(tile_local_coords + Vector2.DOWN, true)
	if south_tile != null and south_tile.north_path != null and south_tile.north_path.is_placed:
		result += 1
	var east_tile := room.get_tile(tile_local_coords + Vector2.RIGHT, true)
	if east_tile != null and east_tile.west_path != null and east_tile.west_path.is_placed:
		result += 1
	if tile.is_inside_door:
		result += 1
	if tile.is_outside_door:
		result += tile.linked_door_tiles.size()
	return result


func _get_segment_endpoint(segment: PathSegment, backside: bool) -> PathSegment:
	var tile := segment.get_parent()
	if tile != null:
		if segment.is_north_not_west:
			if segment.has_backward_flow == backside: # the endpoint outside the tile
				return _get_the_other_segment_in_a_tile(segment, tile.local_coords + Vector2.UP)
			else: # the endpoint inside the tile
				return _get_the_other_segment_in_a_tile(segment, tile.local_coords)
		else:
			segment = tile.west_path
			if segment.has_backward_flow == backside: # the endpoint outside the tile
				return _get_the_other_segment_in_a_tile(segment, tile.local_coords + Vector2.LEFT,)
			else: # the endpoint inside the tile
				return _get_the_other_segment_in_a_tile(segment, tile.local_coords)
	return null


func _get_the_other_segment_in_a_tile(wrong_path: PathSegment, tile_local_coords: Vector2) -> PathSegment:
	var room: GameRoom = wrong_path.get_parent().parent_room
	var tile := room.get_tile(tile_local_coords, true)
	if tile != null:
		if tile.north_path != null and tile.north_path != wrong_path and tile.north_path.is_placed:
			return tile.north_path
		if tile.west_path != null and tile.west_path != wrong_path and tile.west_path.is_placed:
			return tile.west_path
	var south_tile := room.get_tile(tile_local_coords + Vector2.DOWN, true)
	if south_tile != null and south_tile.north_path != null and south_tile.north_path != wrong_path and south_tile.north_path.is_placed:
		return south_tile.north_path
	var east_tile := room.get_tile(tile_local_coords + Vector2.RIGHT, true)
	if east_tile != null and east_tile.west_path != null and east_tile.west_path != wrong_path and east_tile.west_path.is_placed:
		return east_tile.west_path
	return null


func _get_a_segment_in_a_tile(tile: Tile) -> PathSegment:
	if tile != null:
		if tile.north_path != null and tile.north_path.is_placed:
			return tile.north_path
		if tile.west_path != null and tile.west_path.is_placed:
			return tile.west_path
	var south_tile := tile.parent_room.get_tile(tile.local_coords + Vector2.DOWN, true)
	if south_tile != null and south_tile.north_path != null and south_tile.north_path.is_placed:
		return south_tile.north_path
	var east_tile := tile.parent_room.get_tile(tile.local_coords + Vector2.RIGHT, true)
	if east_tile != null and east_tile.west_path != null and east_tile.west_path.is_placed:
		return east_tile.west_path
	return null


func _power_a_segment(target: PathSegment, source_tile_local_coords: Vector2) -> void:
	while target != null:
		var local_coords = target.get_parent().local_coords
		target.has_backward_flow = local_coords != source_tile_local_coords
		target.set_powered(true)
		source_tile_local_coords = _path_segment_tip_local_coords(target)
		_try_power_a_door(source_tile_local_coords, target.get_parent().parent_room)
		target = _get_segment_endpoint(target, false)


func _unpower_a_segment(target: PathSegment) -> void:
	while target != null and target.is_powered:
		target.set_powered(false)
		_try_unpower_a_door(_path_segment_tip_local_coords(target), target.get_parent().parent_room)
		target = _get_segment_endpoint(target, false)


func _path_segment_tip_local_coords(segment: PathSegment) -> Vector2:
	var result: Vector2 = segment.get_parent().local_coords
	if not segment.has_backward_flow:
		result += Vector2.UP if segment.is_north_not_west else Vector2.LEFT
	return result


func _try_power_a_door(source_tile_local_coords: Vector2, room: GameRoom) -> void:
	var source_tile: Tile = room.get_tile(source_tile_local_coords, true)
	assert(not source_tile.is_flow_tip and not source_tile.is_flow_base)
	if source_tile.is_inside_door or source_tile.is_outside_door:
		source_tile.is_flow_base = true
	if not source_tile.linked_door_tiles.is_empty():
		var follow_tile: Tile = source_tile.linked_door_tiles.keys()[0]
		assert(not follow_tile.is_flow_base and not follow_tile.is_flow_tip)
		follow_tile.is_flow_tip = true
		# todo: propagate to another door (check linked_door_tiles size)
		_power_a_segment(_get_a_segment_in_a_tile(follow_tile), follow_tile.local_coords)


func _try_unpower_a_door(source_tile_local_coords: Vector2, room: GameRoom) -> void:
	var source_tile: Tile = room.get_tile(source_tile_local_coords, true)
	if source_tile.is_inside_door or source_tile.is_outside_door:
		assert(source_tile.is_flow_base)
		source_tile.is_flow_base = false
	if not source_tile.linked_door_tiles.is_empty():
		var follow_tile: Tile = source_tile.linked_door_tiles.keys()[0]
		assert(follow_tile.is_flow_tip)
		follow_tile.is_flow_tip = false
		# todo: propagate to another door
		_unpower_a_segment(_get_a_segment_in_a_tile(follow_tile))


func _door_prune(outside_tile: Tile) -> void:
	if _tile_placed_paths_count(outside_tile.local_coords, outside_tile.parent_room) > 1:
		var path_cursor_cache := _path_cursor
		var target_segment := _get_a_segment_in_a_tile(outside_tile)
		while target_segment != null:
			_path_cursor = target_segment
			_try_unplace_path_segment()
			target_segment = _get_a_segment_in_a_tile(outside_tile)
		_path_cursor = path_cursor_cache
	if outside_tile.is_tile_powered():
		outside_tile.is_flow_base = true
