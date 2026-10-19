@tool
extends Resource
class_name PersonResource

@export var person_name: String
@export var person_type: Enums.PersonType
@export var entry_messages: Array[DialogueLine]:
	set(value):
		entry_messages = value
		for i in range(entry_messages.size()):
			if entry_messages[i] == null:
				entry_messages[i] = DialogueLine.new()
@export var avatar: Avatar
@export var entry_message_audio: AudioStream
@export var entry_message_audio_played: bool = false
@export var is_solved: bool = false
