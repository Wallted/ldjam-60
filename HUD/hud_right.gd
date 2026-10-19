extends Control
class_name HUDRight

signal settings_requested
signal help_requested

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_settings_pressed() -> void:
	settings_requested.emit()

func _on_help_pressed() -> void:
	help_requested.emit()
