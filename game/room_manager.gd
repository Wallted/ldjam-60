extends Node2D

var zoom_level : int = 0
var zoom_available: bool
var room_list : Array[GameRoom]
var max_zoom : int

@onready 
var camera_2d: RoomCamera = $"../Camera2D"

func _input(event: InputEvent) -> void:
	if not zoom_available:
		return

	if event is InputEventMouseButton:
		var prev_zoom_level = zoom_level
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			zoom_level = min(zoom_level + 1, max_zoom)
			if zoom_level != prev_zoom_level:
				for _r in room_list:
					var _room: GameRoom = _r
					if _room.zoom_level == zoom_level:
						zoom_on_room(_room)
			
func _ready() -> void:
	for _child in get_parent().get_children():
		if _child is GameRoom:
			var _room : GameRoom = _child
			room_list.append(_room)
			_room.request_focus.connect(_on_zoom_request.bind(_room))
			if _room.zoom_level > max_zoom:
				max_zoom = _room.zoom_level
	
	var dict : Dictionary[int, Array]
	for room in room_list:
		await room.ready
		if room.zoom_level not in dict.keys():
			dict.set(room.zoom_level, [])
		dict[room.zoom_level].append(room)

	var prev_tile_size: Vector2 = Vector2.ZERO
	var prev_position: Vector2 = Vector2.ZERO
	for key in dict.keys():
		print(key)
		var r_l = dict[key]
		for room in r_l:
			room.position = prev_position
			room.position += room.parent_offset * prev_tile_size
			
		prev_tile_size = r_l[0].room_size / r_l[0].grid_size * r_l[0].scale
		prev_position = r_l[0].position
		
	room_list.reverse()
	zoom_on_room(room_list[0])

func zoom_on_room(target_room: GameRoom):
	zoom_level = target_room.zoom_level
	for room in room_list:
		room.set_focus(false, zoom_level - 1)
	target_room.set_focus(true, -1)
	camera_2d.zoom_room(target_room).connect(_on_zoom_finished)
	zoom_available = false

func _on_zoom_request(room: GameRoom) -> void:
	if not zoom_available:
		return
	zoom_on_room(room)

func _on_zoom_finished() -> void:
	zoom_available = true
