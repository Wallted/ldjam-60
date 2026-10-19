extends Node

signal message_sent(
	author: Enums.PersonType,
	message: String,
	duration: float,
	avatar: Texture2D,
)

signal monologue_started(person_type: Enums.PersonType)
signal monologue_ended()

func start_monologue(person_type: Enums.PersonType) -> void:
	var resource = ResourceManagier.get_resource(person_type) as PersonResource
	if not resource.entry_message_audio:
		resource.entry_message_audio_played = true
		return
	if resource.entry_message_audio_played:
		return
	monologue_started.emit(person_type)

func send_message(
	author: Enums.PersonType,
	message: String = '',
	duration: float = 0.0,
):
	message_sent.emit(
		author,
		message,
		duration,
	)


func _send_test_message() -> void:
	var author = Enums.PersonType.ICARUS
	var messages = [
		"Mayday, mayday!",
		"Lecę bo chcę\nLecę, bo życie jest złe",
		"Jestem hardkorem!",
	]
	var message = messages.pick_random()
	if Input.is_key_pressed(KEY_T):
		author = Enums.PersonType.TOURIST
		message = "I like that boulder. That is a *nice* boulder."
	send_message(
		author,
		message,
		2.0,
	)
