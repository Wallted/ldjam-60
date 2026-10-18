extends Node2D

var room_list : Array[GameRoom]
var focus_available: bool = true
var currently_focused_room: GameRoom

@onready 
var camera_2d: RoomCamera = $"../Camera2D"

var _path_cursor: PathSegment
var _path_cursor_north_not_west: bool

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.pressed:
			focus_on_room(currently_focused_room.parent_room)
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
			_room.path_hover.connect(_on_path_mouse_event)

	_snap_rooms_together()

	room_list.reverse()
	focus_on_room(room_list[0])

func _process(_delta: float) -> void:
	for room in room_list:
		room.update_parent()

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

func focus_on_room(target_room: GameRoom):
	if not focus_available or not target_room:
		return

	currently_focused_room = target_room
	for room in room_list:
		room.disable_room()
		if room.zoom_level == target_room.zoom_level - 1:
			room.set_as_pickable()
	
	if _path_cursor != null:
		_path_cursor.set_hovered(false)
	_path_cursor = null
	
	target_room.enable_tiles()
	camera_2d.zoom_room(target_room).connect(_on_zoom_finished)
	focus_available = false

func _on_focus_request(room: GameRoom) -> void:
	focus_on_room(room)

func _on_zoom_finished() -> void:
	focus_available = true


func _on_path_mouse_event(entered: bool, north_not_west: bool, tile: Tile) -> void:
	if tile.input_pickable:
		if entered == false: # no lepiej tak działa lol
			return
		if _path_cursor != null:
			_path_cursor.set_hovered(false)
		if entered:
			_path_cursor = tile.north_path if north_not_west else tile.west_path
			_path_cursor_north_not_west = north_not_west
			var is_eligible_to_hover := true
			if not _path_cursor.is_placed:
				var target_tile_coords: Vector2 = _path_cursor.get_parent().coords + (Vector2.UP if _path_cursor_north_not_west else Vector2.LEFT)
				is_eligible_to_hover = _tile_placed_paths_count(_path_cursor.get_parent().coords, currently_focused_room) < 2
				is_eligible_to_hover = is_eligible_to_hover and _tile_placed_paths_count(target_tile_coords, currently_focused_room) < 2
			if is_eligible_to_hover:
				_path_cursor.set_hovered(true)


func _try_place_path_segment() -> void:
	if _path_cursor != null and _path_cursor.is_hovered:
		_path_cursor.set_placed(true)


func _try_unplace_path_segment() -> void:
	if _path_cursor != null:
		_path_cursor.set_placed(false)


func _remove_tile(tile_coords: Vector2, room: GameRoom) -> void:
	var tile := room.get_tile(tile_coords)
	if tile != null:
		room.tile_list.erase(tile)
		tile.queue_free()
		_trim_paths_of_neighbors(tile_coords, room)


func _trim_paths_of_neighbors(unavailable_tile_coords: Vector2, room: GameRoom) -> void:
	var south_tile := room.get_tile(unavailable_tile_coords + Vector2.DOWN)
	var east_tile := room.get_tile(unavailable_tile_coords + Vector2.RIGHT)
	if south_tile != null:
		south_tile.remove_path(true)
	if east_tile != null:
		east_tile.remove_path(false)


func _tile_placed_paths_count(tile_coords: Vector2, room: GameRoom) -> int:
	var result := 0
	var tile := room.get_tile(tile_coords)
	if tile != null:
		if tile.north_path != null and tile.north_path.is_placed:
			result += 1
		if tile.west_path != null and tile.west_path.is_placed:
			result += 1
	var south_tile := room.get_tile(tile_coords + Vector2.DOWN)
	var east_tile := room.get_tile(tile_coords + Vector2.RIGHT)
	if south_tile != null and south_tile.north_path != null and south_tile.north_path.is_placed:
		result += 1
	if east_tile != null and east_tile.west_path != null and east_tile.west_path.is_placed:
		result += 1
	return result
