#@tool
extends Control
class_name Person

@onready var dust_texture: TextureRect = $MarginContainer/UndiscoveredIndicator/DustTexture

@export var resource: PersonResource:
	set(value):
		resource = value
		person_name = resource.person_name
		avatar = resource.avatar
		is_discovered = resource.is_discovered
		self.status = self.status
		
@export var preview_only: bool = false
@export var is_discovered: bool = false:
	set(value):
		resource.is_discovered = value
		is_discovered = value
		if is_discovered and undiscovered_indicator != null:
			var tween = get_tree().create_tween()
			var fadeout_time = 3.0
			await tween.tween_property(dust_texture, "modulate:a", 0.0, fadeout_time).finished
			undiscovered_indicator.hide()
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
@export var is_solved: bool:
	get():
		return resource.is_solved
	set(value):
		resource.is_solved = value
		if solved_indicator:
			solved_indicator.visible = resource.is_solved
		if not value:
			status = PersonStatus.ASLEEP
		else:
			status = PersonStatus.IDLE

@onready var current_state: TextureRect = %CurrentState
@onready var talking_indicator: PanelContainer = %TalkingIndicator
@onready var solved_indicator: PanelContainer = %SolvedIndicator
@onready var undiscovered_indicator: PanelContainer = %UndiscoveredIndicator

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
	if preview_only or is_discovered:
		undiscovered_indicator.hide()
	


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
