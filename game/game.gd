extends Node2D

signal level_changed(person_type: Enums.PersonType)

@onready var room_manager: Node2D = %RoomManager

func _on_room_manager_room_finished(_room: GameRoom) -> void:
	GameState.set_state(GameState.State.CUTSCENE)
	# do sth
	GameState.set_status(GameState.State.ACTION_FREE)

func _on_room_manager_level_changed(person_type: Enums.PersonType) -> void:
	level_changed.emit(person_type)

func _on_hud_game_mouse_entered() -> void:
	pass

func _on_hud_game_mouse_exited() -> void:
	room_manager.hide_cursor()
