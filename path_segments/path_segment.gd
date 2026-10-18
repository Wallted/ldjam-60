class_name PathSegment
extends Line2D


signal mouse_entered

const POWERED_WIDTH_CURVE = preload("uid://po2k2jpyeddn")
const OFFLINE_WIDTH_CURVE = preload("uid://1fpi08ycayod")

@export var is_the_head_master_workaround_animator_singleton := false # bruh
var is_placed := false
var is_hovered := false
var is_powered := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var glow: Line2D = $Glow


func _ready() -> void:
	if is_the_head_master_workaround_animator_singleton:
		animation_player.play("powered")
	else:
		update_state(is_placed, is_hovered, is_powered)


func update_state(placed: bool, hovered: bool, powered: bool) -> void:
	is_placed = placed
	is_hovered = hovered
	is_powered = powered
	
	if is_placed:
		if is_powered:
			glow.self_modulate = Color("11eef9ff")
			self_modulate = Color("ffffffff")
			width_curve = POWERED_WIDTH_CURVE
		else:
			glow.self_modulate = Color("21150bff")
			self_modulate = Color("362414ff")
			width_curve = OFFLINE_WIDTH_CURVE
		if is_hovered:
			glow.self_modulate = Color("ff0000ff")
	else:
		self_modulate = Color("ffffff00")
		glow.self_modulate = Color("21150bff") if is_hovered else Color("ffffff00")


func set_placed(value: bool) -> void:
	update_state(value, is_hovered, is_powered)


func set_hovered(value: bool) -> void:
	update_state(is_placed, value, is_powered)


func set_powered(value: bool) -> void:
	update_state(is_placed, is_hovered, value)
	

func _on_area_2d_mouse_entered():
	mouse_entered.emit()
