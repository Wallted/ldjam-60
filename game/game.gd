extends Node2D
@onready var hud: HUD = $"../CanvasLayer/HUD"

signal message(author, message)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
var avatars = {
	"pudzian": load("res://icon.svg"),
}


func send_message(
	author: String = '',
	message: String = '',
	duration: float = 0.0,
	avatar: Texture2D = null,
):
	avatar = avatars.get(author)
	hud.send_message(author, message, duration, avatar)
	
