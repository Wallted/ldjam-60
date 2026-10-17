extends Button
@onready var hud_left: HUDLeft = $".."

func _ready():
	self.pressed.connect(_button_pressed)
	
	
func _button_pressed():
	hud_left.send_message('Rick', 'Never gonna give you up', 3.0)
