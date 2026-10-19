extends Node

enum State {
	CUTSCENE,
	PAUSED,
	ACTION_FREE,
	ACTION_PENDING,
}

var state: State 
var prev_state: State

var action_progress: ActionProgress
var label: Label

func _ready() -> void:
	var main = (get_tree().get_current_scene() as Node)
	await main.ready

	action_progress = main.get_node("CanvasLayer").get_node('ActionProgress')
	label = main.get_node("CanvasLayer/HUD/Label")

func pause_game():
	get_tree().paused = true
	action_progress.visible = false
	prev_state = state
	state = State.PAUSED

func unpause_game():
	get_tree().paused = true
	action_progress.visible = true
	state = prev_state

func set_state(new_state: State) -> void:
	state = new_state
	if label:
		label.text = str(GameState.State.keys()[new_state])

func is_state(new_state: State) -> bool:
	return state == new_state
