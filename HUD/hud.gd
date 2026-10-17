extends Control
class_name HUD

@onready var hud_left: HUDLeft = $HUDLeft
@onready var hud_right: HUDRight = $HUDRight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func send_message(message: String):
	hud_left.send_message(message)
