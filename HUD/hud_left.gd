extends Control
class_name HUDLeft

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var chat_window: Control = $ScrollContainer/ChatWindow
@onready var test_button: Button = $Button
@onready var avatar_preview: TextureRect = $AvatarPreview
const SPEECH_BUBBLE = preload("uid://dsg5bxkh2cocg")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_button.pressed.connect(DialogManagier._send_test_message)
	DialogManagier.message_sent.connect(send_message)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func send_message(
	author: String = 'Mariusz Pudzianowski',
	message: String = 'Polska guroooooooom\nxD\nxD\nxD',
	duration: float = 0.0,
	avatar: Texture2D = null,
):
	var last_message = chat_window.get_child(-1) as SpeechBubble
	if last_message != null:
		last_message.force_display()
	var speech_bubble = SPEECH_BUBBLE.instantiate() as SpeechBubble
	speech_bubble.text = message
	speech_bubble.author = author
	speech_bubble.duration = duration
	chat_window.add_child(speech_bubble)
	if avatar != null:
		speech_bubble.avatar.texture = avatar
		avatar_preview.texture = avatar
	get_tree().create_timer(.01).timeout.connect(
		func () -> void:
			scroll_container.set_deferred(
				"scroll_vertical", 
				scroll_container.get_v_scroll_bar().max_value + 200,
			)
	)
