extends StaticBody3D

@onready var marker = $"../../../Marker"
@onready var player = $"../../../Player"

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		marker.transform.origin = position
		player.target = position
