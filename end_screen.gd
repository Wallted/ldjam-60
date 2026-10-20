extends Control

@onready 
var thx: RichTextLabel = $MarginContainer/thx

func fade_in() -> void:
	var tween = get_tree().create_tween()
	var fadeout_time = 3.0
	self.modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, fadeout_time).set_trans(Tween.TRANS_LINEAR)
	await tween.tween_property(thx, "modulate:a", 0.0, 4.0).set_trans(Tween.TRANS_EXPO).finished
