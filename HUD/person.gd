extends Control

@export var is_awake: bool
@export var resource: PersonResource
@onready var current_avatar: Sprite2D = $Node2D/CurrentAvatar
@onready var avatar_active_bg: PanelContainer = $Node2D/AvatarActiveBG

var person_name: String
var avatar: Avatar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	person_name = resource.name
	avatar = resource.avatar
	current_avatar.texture = avatar.asleep
	avatar_active_bg.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Testing placeholder
	if Input.is_action_pressed("speak_1"):
		current_avatar.texture = avatar.talking
		avatar_active_bg.show()
	else:
		current_avatar.texture = avatar.idle
		avatar_active_bg.hide()
