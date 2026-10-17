class_name PathSegment
extends Line2D


const POWERED_WIDTH_CURVE = preload("uid://po2k2jpyeddn")
const OFFLINE_WIDTH_CURVE = preload("uid://1fpi08ycayod")

@export var is_the_head_master_workaround_animator_singleton := false # bruh
@export var is_powered := false # nic nie robi może się przyda

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var glow: Line2D = $Glow


func _ready() -> void:
	if is_the_head_master_workaround_animator_singleton:
		animation_player.play("powered")
	else:
		set_powered(is_powered)

func set_powered(value: bool) -> void:
	if value:
		glow.self_modulate = Color("11eef9")
		self_modulate = Color("ffffff")
		width_curve = POWERED_WIDTH_CURVE
		is_powered = true
	else:
		glow.self_modulate = Color("21150bff")
		self_modulate = Color("362414ff")
		width_curve = OFFLINE_WIDTH_CURVE
		is_powered = false
