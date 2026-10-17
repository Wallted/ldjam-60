extends Control
class_name HUDLeft

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var chat_window: Control = $ScrollContainer/ChatWindow
const SPEECH_BUBBLE = preload("uid://dsg5bxkh2cocg")

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
	if avatar != null:
		speech_bubble.avatar = avatar
	chat_window.add_child(speech_bubble)
	get_tree().create_timer(.01).timeout.connect(
		func () -> void:
			scroll_container.set_deferred(
				"scroll_vertical", 
				scroll_container.get_v_scroll_bar().max_value + 200,
			)
	)
