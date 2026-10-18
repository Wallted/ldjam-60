extends Camera2D
class_name RoomCamera

var tween: Tween

func zoom_room(room : GameRoom) -> Signal:
	var room_size = room.get_size()
	var viewport_size = get_viewport_rect().size
	
	var zoom_x = viewport_size.x / room_size.x
	var zoom_y = viewport_size.y / room_size.y
	
	var zoom_factor = min(zoom_x, zoom_y)
	var _zoom = Vector2(zoom_factor, zoom_factor)
	
	if tween:
		tween.kill()

	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, 'position', room.position, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, 'zoom', _zoom, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.parallel()
	return tween.finished
