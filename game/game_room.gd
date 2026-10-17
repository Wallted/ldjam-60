extends Node2D
class_name GameRoom

signal request_focus

@export
var mock_is_solved: bool

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

@onready var room_area: Area2D = $RoomArea

@onready
var collision_shape_2d: CollisionShape2D = $RoomArea/CollisionShape2D
@onready var sprite_2d: Sprite2D = $RoomArea/Sprite2D

var _tile_scene = preload("res://game/tile.tscn")
var tile_list: Array[Area2D]
var room_size : Vector2 = Vector2(128.0, 128.0)

@onready var grid: Node2D = $Grid

#func _input(event: InputEvent) -> void:
	#print(event)

func _ready() -> void:
	_setup_tiles()
	_setup_doors()
	(collision_shape_2d.shape as RectangleShape2D).size = room_size
	(sprite_2d.texture as PlaceholderTexture2D).size = room_size
	scale = Vector2.ONE * pow(3.0, scale_ratio)

func _setup_tiles() -> void:
	for i in grid_size:
		for j in grid_size:
			var _tile = _tile_scene.instantiate() as Area2D
			
			var tile_size = room_size / grid_size
			var _x = (i * tile_size.x) - room_size.x / 2.0
			var _y = (j * tile_size.y) - room_size.y / 2.0
			_tile.position = Vector2(_x, _y) + tile_size / 2.0
			_tile.scale /= grid_size

			_tile.mouse_entered.connect(_on_tile_mouse_entered.bind(_tile))
			_tile.mouse_exited.connect(_on_tile_mouse_exited.bind(_tile))
			_tile.input_pickable = false

			tile_list.append(_tile)
			grid.add_child(_tile)

			j+=1
		i+=1

func _setup_doors() -> void:
	var step = 3.0 # todo: magic number
	for door in doors:
		var _door_txt = Sprite2D.new()
		_door_txt.modulate *= 10.0 # todo: remove
		_door_txt.texture = load('res://icon.svg') # todo: remove
		_door_txt.position -= room_size / 2.0
		_door_txt.position += room_size / step * door.coord + room_size / (step * 2.0)
		_door_txt.scale /= grid_size * 2.0
		_door_txt.position += room_size / (step * 2.0) * door.side
		add_child(_door_txt)

func is_solved() -> bool:
	return mock_is_solved

func get_size() -> Vector2:
	return room_size * scale
	
func set_focus(enabled: bool, _zoom_level) -> void:
	room_area.input_pickable = _zoom_level == zoom_level
	for _item in tile_list:
		var _tile : Area2D = _item
		_tile.input_pickable = enabled

func _on_tile_mouse_entered(_tile: Area2D) -> void:
	_tile.modulate *= 10.0 # todo: remove

func _on_tile_mouse_exited(_tile: Area2D) -> void:
	_tile.modulate /= 10.0 # todo: remove

func _on_room_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print('pressed room %s' % name)
			request_focus.emit()


func _on_room_area_mouse_entered() -> void:
	sprite_2d.material.set("shader_parameter/selected",	true);

func _on_room_area_mouse_exited() -> void:
	sprite_2d.material.set("shader_parameter/selected",	false);
