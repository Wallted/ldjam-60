extends Node

@onready var color_rect: ColorRect = $CanvasLayer/TitleScreen/ColorRect
@onready var button: Button = $CanvasLayer/TitleScreen/Button
@onready var title_screen: Control = $CanvasLayer/TitleScreen
@onready var title_text_scroll_container: ScrollContainer = $CanvasLayer/TitleScreen/TitleTextScrollContainer

func _ready() -> void:
	GameState.pause_game()
	$MainAudioStream.play()

func _on_title_button_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, 'color:a', 0.0, 0.75).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_delete)
	button.visible = false
	title_text_scroll_container.visible = false

func _delete() -> void:
	GameState.unpause_game()
	title_screen.queue_free()
