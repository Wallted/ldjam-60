@tool
extends Control
class_name SpeechBubble

@onready var panel_container: PanelContainer = $PanelContainer
@onready var text_node: RichTextLabel = $PanelContainer/Text

@export var author = '<placeholder author>'
@export_multiline var text: String = '<placeholder text>':
	set(value):
		text = value
		$PanelContainer/Text.text = value

func _ready():
	text_node.text = text

	text_node.fit_content = true
	text_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	text_node.resized.connect(_update_bubble_size)
	text_node.minimum_size_changed.connect(_update_bubble_size)

	call_deferred("_update_bubble_size")

func _update_bubble_size() -> void:
	custom_minimum_size.y = panel_container.get_combined_minimum_size().y
