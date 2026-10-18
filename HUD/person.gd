extends Control

@export var person_id: int
@onready var avatar: Sprite2D = $Node2D/Avatar
@onready var avatar_active_bg: PanelContainer = $Node2D/AvatarActiveBG

var texture_types = {}
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	avatar_active_bg.hide()
	texture_types = {
		"sleeping": load("res://img/placeholder_%s_idle.png" % [person_id]),
		"awake": load("res://img/placeholder_%s_talking_2.png" % [person_id])
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Testing placeholder
	if Input.is_action_pressed("speak_%s" % [person_id]):
		avatar_active_bg.show()
		avatar.texture = texture_types.get("awake")
	else:
		avatar_active_bg.hide()
		avatar.texture = texture_types.get("sleeping")
