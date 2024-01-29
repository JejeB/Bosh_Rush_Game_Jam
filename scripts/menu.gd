extends Control

@onready var main_scene = "res://scenes/main.tscn"
@onready var mask_texture: TextureRect = $SeparateMask/VBoxContainer/CenterContainer/MaskTexture

var follower_point

func _ready():
	#calculate pivot point
	call_deferred("calculate_pivot_offset")
	
func _process(delta):
	#print(get_global_mouse_position())
	#print(mask_texture.position)
	
	var angle_to_mouse = mask_texture.pivot_offset.angle_to(get_global_mouse_position())
	print(rad_to_deg(angle_to_mouse))
	#print(mask_texture.global_position)
	
	#mask_texture.set_rotation(angle_to_mouse)
	
func _on_start_game_button_down():
	get_tree().change_scene_to_file(main_scene)


func calculate_pivot_offset():
	var middle_position = mask_texture.size/2
	middle_position.x = mask_texture.global_position.x + middle_position.x
	middle_position.y = mask_texture.global_position.y + middle_position.y
	mask_texture.pivot_offset = middle_position
	
	follower_point = mask_texture.size/2
	follower_point.y = mask_texture.global_position.y + follower_point.y
	
	print(mask_texture.pivot_offset)
	print(follower_point)
