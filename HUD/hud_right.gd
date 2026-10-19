extends Control
class_name HUDRight
@onready var grid_container: GridContainer = $GridContainer

signal settings_requested
signal help_requested
@onready var sfx_stream: AudioStreamPlayer = $"../../../MainAudioStream/SFXStream"
const ODDYMIACZ = preload("uid://dmyc208cgyl31")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManagier.monologue_started.connect(_on_monologue_start)
	DialogManagier.monologue_ended.connect(_on_monologue_end)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_settings_pressed() -> void:
	settings_requested.emit()

func _on_help_pressed() -> void:
	help_requested.emit()
	
	
func _on_monologue_start(person_type: Enums.PersonType) -> void:
	for person in grid_container.get_children():
		person = person as Person
		if person.type == person_type:
			person.set_talking()

func _on_monologue_end() -> void:
	for person in grid_container.get_children():
		person = person as Person
		if person.is_talking():
			person.set_idle()


func _on_game_room_powered_changed(person_type: Enums.PersonType, powered: bool) -> void:
	for person in grid_container.get_children():
		person = person as Person
		if person.type == person_type:
			person.is_solved = powered


func _on_game_level_changed(person_type: Enums.PersonType) -> void:
	for person in grid_container.get_children():
		person = person as Person
		if person.type == person_type:
			if not person.is_discovered:
				sfx_stream.stream = ODDYMIACZ
				sfx_stream.play()
			person.is_discovered = true
