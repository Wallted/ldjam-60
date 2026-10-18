extends Control
class_name HUDLeft

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var chat_window: Control = $ScrollContainer/ChatWindow
const SPEECH_BUBBLE = preload("uid://dsg5bxkh2cocg")

signal test_button_pressed(author: String, message: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	get_tree().create_timer(.01).timeout.connect(
		func () -> void:
			scroll_container.set_deferred(
				"scroll_vertical", 
				scroll_container.get_v_scroll_bar().max_value + 200,
			)
	)


func _on_button_pressed() -> void:
	var author = "pudzian"
	var message = "polska gurooooom"
	
	if Input.is_action_pressed("speak_1"):
		author = "1"
		message = "Never gonna give you up"
	if Input.is_action_pressed("speak_2"):
		author = "2"
		message = "Never gonna let you down"
	if Input.is_action_pressed("speak_3"):
		author = "3"
		message = "Never gonna run around"
	if Input.is_action_pressed("speak_4"):
		author = "4"
		message = "And desert you"
	test_button_pressed.emit(author, message)
