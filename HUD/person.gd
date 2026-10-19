extends Control
class_name Person

@export var resource: PersonResource
@export var preview_only: bool = false
@onready var current_state: TextureRect = %CurrentState
@onready var talking_indicator: PanelContainer = %TalkingIndicator


var person_name: String
var avatar: Avatar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()

func update() -> void:
	person_name = resource.person_name
	avatar = resource.avatar
	if preview_only:
		set_asleep()
	else:
		set_idle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Testing placeholder
	if preview_only:
		return
	if Input.is_action_pressed("speak_1"):
		set_talking()
	else:
		set_idle()


func set_asleep() -> void:
	current_state.texture = avatar.asleep
	talking_indicator.hide()


func set_idle() -> void:
	current_state.texture = avatar.idle
	talking_indicator.hide()


func set_talking() -> void:
	current_state.texture = avatar.talking
	talking_indicator.show()
