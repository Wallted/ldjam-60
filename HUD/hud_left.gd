extends Control
class_name HUDLeft

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var chat_window: Control = $ScrollContainer/ChatWindow
const SPEECH_BUBBLE = preload("uid://dsg5bxkh2cocg")
@onready var current_level_person: Person = $CurrentLevelPerson
@onready var dialog_stream: AudioStreamPlayer = $"../../../MainAudioStream/DialogStream"
@onready var message_timers: Node = $MessageTimers

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManagier.message_sent.connect(send_message)
	DialogManagier.monologue_ended.connect(_on_monologue_end)
	DialogManagier.monologue_started.connect(_on_monologue_start)
	dialog_stream.finished.connect(func (): DialogManagier.end_monologue())


func _scroll_to_bottom(delay: float = 0.0) -> void:
	get_tree().create_timer(delay + .01).timeout.connect(
		func () -> void:
			scroll_container.set_deferred(
				"scroll_vertical",
				scroll_container.get_v_scroll_bar().max_value + 200,
			)
	)

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
	_scroll_to_bottom()

func queue_message(
	person_type: Enums.PersonType,
	message: String,
	duration: float,
	delay: float,
) -> void:
	var timer := MessageTimer.new()
	timer.person_type = person_type
	timer.message = message
	timer.duration = duration
	timer.one_shot = true
	message_timers.add_child(timer)
	timer.start(delay)
	timer.timeout.connect(timer.queue_free)
	timer.timeout.connect(
		func () -> void:
			send_message(person_type, message, duration)
	)


func _on_monologue_start(person_type: Enums.PersonType) -> void:
	var resource = ResourceManagier.get_resource(person_type)
	if resource.entry_message_audio and not resource.entry_message_audio_played:
		dialog_stream.stream = resource.entry_message_audio
		dialog_stream.play()
		resource.entry_message_audio_played = true

	for dialogue_line in resource.entry_messages:
		if dialogue_line.is_spoken:
			continue
		queue_message(
			person_type,
			dialogue_line.message,
			dialogue_line.duration,
			dialogue_line.timestamp
		)
		dialogue_line.is_spoken = true


func _on_monologue_end() -> void:
	if current_level_person == null:
		return
	
	dialog_stream.stop()
	for child in message_timers.get_children():
		child.stop()
		child.emit_signal("timeout")


func _on_game_level_changed(person_type: Enums.PersonType, powered: bool) -> void:
	var resource = ResourceManagier.get_resource(person_type)
	current_level_person.resource = resource
	current_level_person.resource.is_discovered = true
	current_level_person.is_solved = powered


func _on_game_room_powered_changed(person_type: Enums.PersonType, powered: bool) -> void:
	if current_level_person.resource.person_type == person_type:
		current_level_person.is_solved = powered
