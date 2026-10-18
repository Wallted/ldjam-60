extends Control
class_name HUDLeft

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var chat_window: Control = $ScrollContainer/ChatWindow
@onready var test_button: Button = $Button
const SPEECH_BUBBLE = preload("uid://dsg5bxkh2cocg")
@onready var current_level_person: Person = $CurrentLevelPerson


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_button.pressed.connect(DialogManagier._send_test_message)
	DialogManagier.message_sent.connect(send_message)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


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
	speech_bubble.avatar.texture = resource.avatar
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
	current_level_person.resource = ResourceManagier.get_resource(person_type)
	current_level_person.update()
