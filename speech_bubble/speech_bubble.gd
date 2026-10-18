@tool
extends Control
class_name SpeechBubble

@onready var text_container: PanelContainer = $TextContainer
@onready var text_node: RichTextLabel = $TextContainer/Text
@onready var author_node: RichTextLabel = $AuthorContainer/Author

@onready var avatar: TextureRect = $Avatar
@export var duration: float = 0.0

@export_multiline var author: String = '<placeholder author>':
	set(value):
		author = value
		$AuthorContainer/Author.text = value

@export_multiline var text: String = '<placeholder text>':
	set(value):
		text = value
		$TextContainer/Text.text = value

func _process(delta: float) -> void:
	if duration:
		if text_node.visible_ratio <= 1.0:
			text_node.visible_ratio += delta/duration
	else:
		text_node.visible_ratio = 1.0

func _ready():
	text_node.text = text
	text_node.visible_ratio = 0.0

	text_node.fit_content = true
	text_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	text_node.resized.connect(_update_bubble_size)
	text_node.minimum_size_changed.connect(_update_bubble_size)

	call_deferred("_update_bubble_size")

func _update_bubble_size() -> void:
	custom_minimum_size.y = text_container.get_combined_minimum_size().y + avatar.size.y
	
func force_display():
	text_node.visible_ratio = 1.0
