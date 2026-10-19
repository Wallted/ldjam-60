extends AudioStreamPlayer


func _ready() -> void:
	DialogManagier.monologue_ended.connect(_on_monologue_end)
	
func _on_monologue_end() -> void:
	self.stop()
