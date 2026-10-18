extends Node2D
@onready var hud: HUD = $"../CanvasLayer/HUD"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManagier.message_sent.connect(_on_message_sent)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
var avatars = {
	"pudzian": preload("res://icon.svg"),
	"1": preload("uid://cjilmcj7xjcec"),
	"2": preload("uid://gb72nd0ogcis"),
	"3": preload("uid://djt4o420wvuig"),
	"4": preload("uid://yjtwwdhgh4ca"),
}
	
func send_message(
	author: String = '',
	message: String = '',
	duration: float = 0.0,
	avatar: Texture2D = null,
):
	avatar = avatars.get(author)
	hud.send_message(author, message, duration, avatar)
	

func _on_message_sent(author: String, message: String) -> void:
	send_message(author, message, 2.0)
	
func _on_hud_left_test_button_pressed(author: String, message: String) -> void:
	send_message(author, message, 2.0)
