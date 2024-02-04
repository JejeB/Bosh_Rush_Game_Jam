extends Node3D

@onready var animation : AnimationPlayer = $CameraAnimation
@onready var boss = $"../boss1/AnimationPlayer"
@onready var control_node: Control = $"../Control"
@onready var main_scene = "res://scenes/main.tscn"

enum State {PLAY, STOP, TRANSITION}

var cinema_state = State.PLAY

# Called when the node enters the scene tree for the first time.
func _ready():
	boss.play("boss idle1")
	animation.play("camera_cut_scene")


func _on_camera_animation_animation_finished(anim_name):
	if anim_name == "camera_cut_scene":
		animation.play("RESET")
		cinema_state = State.STOP

func add_boss_name():
	control_node.show()

func boss_display_hide_attack_zone():
	pass
	
func begin_combat():
	get_tree().change_scene_to_file(main_scene)

func display_area_effect():
	pass
