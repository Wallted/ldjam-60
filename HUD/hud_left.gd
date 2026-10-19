extends Control
class_name HUDLeft

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var chat_window: Control = $ScrollContainer/ChatWindow
const SPEECH_BUBBLE = preload("uid://dsg5bxkh2cocg")
@onready var current_level_person: Person = $CurrentLevelPerson
@onready var dialog_stream: AudioStreamPlayer = $"../../../MainAudioStream/DialogStream"

var _test_button_pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManagier.message_sent.connect(send_message)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_W):
		if not _test_button_pressed:
			DialogManagier._send_test_message()
		_test_button_pressed = true
	else:
		_test_button_pressed = false


func send_message(
	author: Enums.PersonType,
	message: String = '',
	duration: float = 0.0,
):
	var resource = ResourceManagier.get_resource(author)

	var last_message = chat_window.get_child(-1) as SpeechBubble
	if last_message != null:
		last_message.force_display()
	var speech_bubble = SPEECH_BUBBLE.instantiate() as SpeechBubble
	speech_bubble.text = message
	speech_bubble.author = resource.person_name
	speech_bubble.duration = duration
	chat_window.add_child(speech_bubble)
	speech_bubble.avatar.texture = resource.avatar.idle
	get_tree().create_timer(.01).timeout.connect(
		func () -> void:
			scroll_container.set_deferred(
				"scroll_vertical",
				scroll_container.get_v_scroll_bar().max_value + 200,
			)
	)


func _on_game_level_changed(person_type: Enums.PersonType) -> void:
	if current_level_person == null:
		return
	var resource = ResourceManagier.get_resource(person_type)
	current_level_person.resource = resource
	current_level_person.update()

	dialog_stream.stop()
	if resource.entry_message_audio:
		dialog_stream.stream = resource.entry_message_audio
		dialog_stream.play()

	for dialogue_line in resource.entry_messages:
		if dialogue_line.is_spoken:
			continue
		send_message(person_type, dialogue_line.message)
		dialogue_line.is_spoken = true
