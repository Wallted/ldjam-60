extends Node

signal message_sent(
	author: String,
	message: String,
	duration: float,
	avatar: Texture2D,
)


func send_message(
	author: String = '',
	message: String = '',
	duration: float = 0.0,
	avatar: Texture2D = null,
):
	var avatars: Dictionary = {
		"pudzian": preload("res://icon.svg"),
		"1": preload("uid://cjilmcj7xjcec"),
		"2": preload("uid://gb72nd0ogcis"),
		"3": preload("uid://djt4o420wvuig"),
		"4": preload("uid://yjtwwdhgh4ca"),
	}
	
	avatar = avatars.get(author)
	if avatar == null:
		avatar = ResourceManagier.get_avatar(author).idle
		
	message_sent.emit(
		author,
		message,
		duration,
		avatar,
	)


func _send_test_message() -> void:
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
	if Input.is_key_pressed(KEY_T):
		author = "tourist"
		message = "I like that boulder. That is a *nice* boulder."
	if Input.is_key_pressed(KEY_I):
		author = "icarus"
		message = "Mayday, mayday!"
	send_message(
		author,
		message,
		2.0,
	)
