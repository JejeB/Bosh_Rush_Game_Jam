extends Node3D

var is_enable:bool = false

func _ready():
	disable()

func disable():
	visible = false
	is_enable = false
	
func enable():
	visible = true
	is_enable = true

func _on_area_3d_body_entered(body:Node3D):
	if is_enable and (body.has_method("hurt")):
		body.hurt()
