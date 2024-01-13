extends Node3D

@export var player: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and player.swap_is_activated:
			
		var object_position = self.get_position()
		var player_position = player.position
		
		# change position
		self.set_position(player_position)
		player.set_position(object_position)
		player.target = Vector3.ZERO
		
		print("position clicke: " + str(position))
		print("player position: "+ str(player.position))
		print("object position: "+ str(object_position))
		
