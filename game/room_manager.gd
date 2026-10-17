extends Node2D

@onready var camera_2d: RoomCamera = $"../Camera2D"
var room_list : Array[GameRoom]

var zoom_level : int = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			zoom_level = min(zoom_level + 1, room_list.size() - 1)
			change_zoom()
			
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			zoom_level = max(zoom_level - 1, 0)
			change_zoom()

func _ready() -> void:
	for _child in get_children():
		if _child is GameRoom:
			room_list.append(_child)
	room_list.reverse()
	camera_2d.zoom_room(room_list[0], true)

func _process(_delta: float) -> void:
	pass

func change_zoom():
	camera_2d.zoom_room(room_list[zoom_level], false)
