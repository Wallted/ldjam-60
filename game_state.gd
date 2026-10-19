extends Node

enum State {
	CUTSCENE,
	PAUSED,
	ACTION_FREE,
	ACTION_PENDING,
	LEVEL_UNLOCKED,
}

var state: State :
	set(_state):
		state = _state
		if label:
			label.text = str(GameState.State.keys()[_state])
var prev_state: State
var prev_mouse_mode: Input.MouseMode

var action_progress: ActionProgress
var label: Label
var skip_button: Button

var zoom_tween_value : float = 0.5

var button_tween: Tween

func _ready() -> void:
	var main = (get_tree().get_current_scene() as Node)
	await main.ready

	action_progress = main.get_node("CanvasLayer").get_node('ActionProgress')
	label = main.get_node("CanvasLayer/HUD/Label")
	skip_button = main.get_node("CanvasLayer/SkipButton")

func pause_game():
	if state == GameState.State.PAUSED:
		return
	get_tree().paused = true
	if action_progress:
		action_progress.visible = false
	prev_state = state
	state = State.PAUSED

	prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func unpause_game():
	if state != GameState.State.PAUSED:
		return
	get_tree().paused = false
	action_progress.visible = true
	state = prev_state
	Input.mouse_mode = prev_mouse_mode

func enable_cutscene():
	state = GameState.State.CUTSCENE
	if button_tween:
		button_tween.kill()
	button_tween = get_tree().create_tween()
	skip_button.modulate.a = 0.0
	button_tween.tween_property(skip_button, "modulate:a", 0.0, 1.5)
	button_tween.tween_property(skip_button, "modulate:a", Color.WHITE.a, 0.5)
	skip_button.visible = true
	if not skip_button.is_connected('pressed', disable_cutscene):
		skip_button.pressed.connect(disable_cutscene)

func disable_cutscene():
	state = GameState.State.ACTION_FREE
	DialogManagier.monologue_ended.emit()
	skip_button.visible = false

func set_state(new_state: State) -> void:
	state = new_state

func is_state(new_state: State) -> bool:
	return state == new_state

func set_zoom_tween(_value: float):
	zoom_tween_value = _value
