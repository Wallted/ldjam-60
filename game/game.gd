extends Node2D

signal level_changed(person_type: Enums.PersonType)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_room_manager_level_changed(person_type: Enums.PersonType) -> void:
	level_changed.emit(person_type)
