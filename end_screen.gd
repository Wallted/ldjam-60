extends Control


func fade_in() -> void:
	var tween = get_tree().create_tween()
	var fadeout_time = 3.0
	self.modulate.a = 0.0
	await tween.tween_property(self, "modulate:a", 1.0, fadeout_time).finished
