extends Control
class_name HUD

@onready var hud_left: HUDLeft = $HUDLeft
@onready var hud_right: HUDRight = $HUDRight
@onready var settings_menu: Settings = $Settings
@onready var help_menu: Help = $Help

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings_menu.hide()
	help_menu.hide()
	hud_right.settings_requested.connect(_on_settings_pressed)
	hud_right.help_requested.connect(_on_help_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_settings_pressed() -> void:
	if help_menu.visible:
		help_menu.visible = false
	settings_menu.visible = not settings_menu.visible

func _on_help_pressed() -> void:
	if settings_menu.visible:
		settings_menu.visible = false
	help_menu.visible = not help_menu.visible
