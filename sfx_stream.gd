extends AudioStreamPlayer
@export var magicPathAudio :AudioStream = preload("uid://b1knn6fd0h6ne")
@export var insideAudio :AudioStream = preload("uid://buf2gdc58ngyv")
@export var outsideAudio :AudioStream = preload("uid://d0s8sgddpjdn3")
@export var pathAudio :AudioStream = preload("uid://dno1xq4wh8pum")
@export var rotateAudio :AudioStream = preload("uid://dccwj6xwdo57r")
@export var unpathAudio :AudioStream = preload("uid://d3lmn8q0uwypl")


func _on_game_placed_powered_path() -> void:
	$".".stream = magicPathAudio
	$".".play()

func _on_game_placed_unpowered_path() -> void:
	$".".stream = pathAudio
	$".".play()


func _on_game_rotate_room() -> void:
	$".".stream = rotateAudio
	$".".play()

func _on_game_unplace_path() -> void:
	$".".stream = unpathAudio
	$".".play()


func _on_game_zoom_in_room() -> void:
	$".".stream = insideAudio
	$".".play()


func _on_game_zoom_out_room() -> void:
	$".".stream = outsideAudio
	$".".play()
