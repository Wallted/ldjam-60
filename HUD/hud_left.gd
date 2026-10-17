extends Control
class_name HUDLeft


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
):
	var speech_bubble = SPEECH_BUBBLE.instantiate() as SpeechBubble
	speech_bubble.text = message
	speech_bubble.author = author
	chat_window.add_child(speech_bubble)
