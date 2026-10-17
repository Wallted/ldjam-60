class_name PathSegment
extends Line2D


const POWERED_TEXTURE: Texture = preload("uid://biriqu2hj8yeq")
const OFFLINE_TEXTURE: Texture = preload("uid://dkblonl3jf2om")

var is_powered := false # nic nie robi może się przyda

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	set_powered(is_powered)

func set_powered(value: bool) -> void:
	if value:
		texture = POWERED_TEXTURE
		animation_player.play("powered")
		modulate = Color("80eeffff")
		is_powered = true
	else:
		texture = OFFLINE_TEXTURE
		animation_player.stop()
		modulate = Color("694323")
		is_powered = false
