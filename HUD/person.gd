@tool
extends Control
class_name Person

@export var resource: PersonResource:
	set(value):
		resource = value
		person_name = resource.person_name
		avatar = resource.avatar
		self.status = self.status
@export var preview_only: bool = false
@export var status: PersonStatus = PersonStatus.ASLEEP:
	set(value):
		status = value
		if current_state == null:
			return
		current_state.texture = {
			PersonStatus.ASLEEP: avatar.asleep,
			PersonStatus.IDLE: avatar.idle,
			PersonStatus.TALKING: avatar.talking,
		}[value]
@export var type: Enums.PersonType:
	get():
		return resource.person_type

@onready var current_state: TextureRect = %CurrentState
@onready var talking_indicator: PanelContainer = %TalkingIndicator

enum PersonStatus {
	ASLEEP,
	IDLE,
	TALKING,
}

var person_name: String
var avatar: Avatar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	person_name = resource.person_name
	avatar = resource.avatar
	self.status = status  # refresh status when it's available


func set_asleep() -> void:
	status = PersonStatus.ASLEEP
	talking_indicator.hide()


func set_idle() -> void:
	status = PersonStatus.IDLE
	talking_indicator.hide()


func set_talking() -> void:
	status = PersonStatus.TALKING
	talking_indicator.show()


func is_talking() -> bool:
	return self.status == PersonStatus.TALKING
