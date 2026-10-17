extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Testing placeholder
	if Input.is_action_pressed("speak_1"):
		$Node2D/Placeholder_1.play()
	else:
		$Node2D/Placeholder_1.stop()
	
