extends Control

@onready var main_scene = "res://scenes/main.tscn"

func _on_start_game_button_down():
	get_tree().change_scene_to_file(main_scene)
