extends Node3D

@export var player: CharacterBody3D

@onready var rock : MeshInstance3D = $rock

func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and player.swap_state_mode == player.Swap_State.SWAP:

		var object_position = self.get_position()
		var player_position = player.position
		
		# change position
		self.set_position(player_position)
		player.set_position(object_position)
		
		# Cooldown the spell for the player
		player.swap_state_mode = player.Swap_State.COOLDOWN
		player.swap_cooldown_timer.start()
		
		# debug value
		#print("position clicke: " + str(position))
		#print("player position: "+ str(player.position))
		#print("object position: "+ str(object_position))
		



func _on_static_body_3d_mouse_entered():
	#var newMaterial = Material.new()
	#newMaterial.albedo_color = Color(0.92, 0.69, 0.13, 1.0)
	#rock.material_override = newMaterial
	
	if player.swap_state_mode == player.Swap_State.SWAP:

		var object_position = self.get_position()
		var player_position = player.position
		
		# change position
		self.set_position(player_position)
		player.set_position(object_position)
		
		# Cooldown the spell for the player
		player.swap_state_mode = player.Swap_State.COOLDOWN
		player.swap_cooldown_timer.start()


func _on_static_body_3d_mouse_exited():
	rock.material_override = null
