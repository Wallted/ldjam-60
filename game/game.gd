extends Node2D

signal level_changed(person_type: Enums.PersonType)
signal room_powered_changed(person_type: Enums.PersonType, powered: bool)

@onready var room_manager: Node2D = %RoomManager

func _on_room_manager_room_finished(_room: GameRoom) -> void:
	prints('room finished:', _room.person_name, _room.name)
	GameState.enable_cutscene()
	DialogManagier.monologue_ended.emit()
	DialogManagier.start_monologue(_room.person_name)

func _on_room_manager_level_changed(person_type: Enums.PersonType) -> void:
	level_changed.emit(person_type)
	DialogManagier.monologue_ended.emit()
	DialogManagier.start_monologue(person_type)

func _on_hud_game_mouse_entered() -> void:
	pass

func _on_hud_game_mouse_exited() -> void:
	room_manager.hide_cursor()


func _on_room_manager_room_powered_changed(person_type: Enums.PersonType, powered: bool) -> void:
	room_powered_changed.emit(person_type, powered)
