extends Node3D

@onready var animation : AnimationPlayer = $CameraAnimation
@onready var boss: CharacterBody3D = $"../Boss"
@onready var control_node: Control = $"../Control"
@onready var main_scene = "res://scenes/main.tscn"

enum State {PLAY, STOP, TRANSITION}

var cinema_state = State.PLAY

# Called when the node enters the scene tree for the first time.
func _ready():
	boss.jump_path.visible = false
	animation.play("camera_cut_scene")


func _on_camera_animation_animation_finished(anim_name):
	if anim_name == "camera_cut_scene":
		animation.play("RESET")
		cinema_state = State.STOP

func add_boss_name():
	control_node.show()

func boss_display_hide_attack_zone():
	boss.zone_attack_cut_scene = false
	
func begin_combat():
	get_tree().change_scene_to_file(main_scene)
