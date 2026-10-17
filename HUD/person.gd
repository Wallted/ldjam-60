extends Control

@export var person_id: int
@onready var avatar: AnimatedSprite2D = $Node2D/Avatar
@onready var avatar_active_bg: PanelContainer = $Node2D/AvatarActiveBG

var animation_types = {}
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	avatar_active_bg.hide()
	animation_types = {
		"idle": "idle_%s" % [person_id],
		"talk": "talking_%s" % [person_id]
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Testing placeholder
	if Input.is_action_pressed("speak_%s" % [person_id]):
		avatar_active_bg.show()
		avatar.play(animation_types.get("talk"))
	else:
		avatar_active_bg.hide()
		avatar.play(animation_types.get("idle"))
		avatar.stop()
