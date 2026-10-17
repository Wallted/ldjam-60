extends Control

@export var person_id: int
@onready var avatar: AnimatedSprite2D = $Node2D/Avatar

var animation_types = {}
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_types = {
		"idle": "idle_%s" % [person_id],
		"talk": "talking_%s" % [person_id]
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Testing placeholder
	if Input.is_action_pressed("speak_%s" % [person_id]):
		avatar.play(animation_types.get("talk"))
	else:
		avatar.play(animation_types.get("idle"))
		avatar.stop()
	
