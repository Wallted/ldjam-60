class_name ActionProgress
extends Control


func _process(_delta: float) -> void:
	global_position = get_viewport().get_mouse_position()
	if not progress:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

var progress := 0.0 :
	set(_progress):
		queue_redraw()
		if _progress == 1.0:
			progress = 0.0
		else:
			progress = _progress

func _draw() -> void:
	draw_arc(
		Vector2(0, 0),
		10.0,
		0.0,
		TAU * progress,
		32,
		Color.AQUA / 1.5,
		6
	)
