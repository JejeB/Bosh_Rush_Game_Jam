extends Control

@onready var main_scene = "res://scenes/cut_scene.tscn"
@onready var tuto_scene = "res://scenes/tutorial.tscn"
@onready var mask_sprite: Sprite2D = $GridContainer/CenterContainer/MaskSprite
@onready var animation_player: AnimationPlayer = $GridContainer/CenterContainer/AnimationPlayer
@onready var mask_timer: Timer = $GridContainer/CenterContainer/MaskClickedTimer

var click_count :int = 0

func _process(delta):
	
	if Input.is_action_just_pressed("click_gauche"):
		animation_player.play("menu_animation")
		mask_timer.start()
		click_count += 1
		
	elif click_count >= 3:
		print("[Play] Easter egg sound")
		click_count = 0
	else :
		mask_sprite.look_at(get_global_mouse_position())

# go to the main scene
func _on_start_game_button_down():
	get_tree().change_scene_to_file(main_scene)
	FMODRuntime.play_one_shot_path("event:/SFX/UI/UIClick")

# Animation is finished
func _on_mask_clicked_timer_timeout():
	animation_player.stop()


func _on_tuto_button_button_down():
	get_tree().change_scene_to_file(tuto_scene)
	FMODRuntime.play_one_shot_path("event:/SFX/UI/UIClick")
