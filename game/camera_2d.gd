extends Camera2D
class_name RoomCamera

var tween: Tween
@onready var action_progress: ActionProgress = $"../../CanvasLayer/HUD/ActionProgress"

func _calculate_zoom(room: GameRoom) -> Vector2:
	var room_size = room.get_size()
	var viewport_size = get_viewport_rect().size

	var zoom_x = viewport_size.x / room_size.x
	var zoom_y = viewport_size.y / room_size.y

	var zoom_factor = min(zoom_x, zoom_y)
	var _zoom = Vector2(zoom_factor, zoom_factor)

	return _zoom

func zoom_room(room: GameRoom) -> void:
	position = room.position
	zoom = _calculate_zoom(room)

func tween_zoom_room(room : GameRoom) -> Signal:
	if tween:
		tween.kill()

	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, 'position', room.position, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, 'zoom', _calculate_zoom(room), 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(action_progress, 'progress', 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel()
	return tween.finished
