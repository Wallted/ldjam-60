extends Control

@onready var text_node: RichTextLabel = $MarginContainer/TitleText

@export var duration: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_node.visible_ratio = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if duration:
		if text_node.visible_ratio <= 1.0:
			text_node.visible_ratio += delta/duration
	else:
		text_node.visible_ratio = 1.0
