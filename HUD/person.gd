extends Control

@export var person_id: String
@export var is_awake: bool
@onready var avatar: Sprite2D = $Node2D/Avatar
@onready var avatar_active_bg: PanelContainer = $Node2D/AvatarActiveBG
var avatar_instance = Avatars.new()
#@onready var avatars_res: GDScript = load("res://HUD/res/avatars.gd")
#var avatar_instance: Avatars = avatars_res.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	avatar_active_bg.hide()
	avatar.texture = avatar_instance.avatars.get(person_id).get("sleeping")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Testing placeholder
	if Input.is_action_pressed("speak_1"):
		avatar_active_bg.show()
		avatar.texture = avatar_instance.avatars.get(person_id).get("awake")
	else:
		avatar_active_bg.hide()
		avatar.texture = avatar_instance.avatars.get(person_id).get("sleeping")
