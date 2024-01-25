extends Node3D

@export var player: CharacterBody3D
@export var hover_range: int = 10
@export var hover_color: Color = Color(0.92, 0.69, 0.13, 1.0)

@onready var rock : MeshInstance3D = $rock
@onready var magic : GPUParticles3D = $MagicParticles
@onready var magic_timer : Timer = $MagicTimer



func _ready():
	# connect signal to swap position sended by player
	player.connect("swap_positon", handle_signal_for_position_swap)
	
	# give the range decided for the hover to the spell indicator
	player.spell_range = hover_range

# for the mouse moving
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
	
	var distance = player.global_position.distance_to(self.global_position)
	#print("distance " + str(distance))
	
	# range between the player and the object is in range
	if distance <= hover_range :
		# hover color when mouse is on the staticbody3d
		var newMaterial = StandardMaterial3D.new()
		newMaterial.albedo_color = hover_color
		rock.material_override = newMaterial
		FMODRuntime.play_one_shot_path("event:/SFX/Swap/SwapHover")
		
		# give the enter hover signal
		player.hover_on_swappable_object = true
		player.swappable_object_position = self.get_position()

func _on_static_body_3d_mouse_exited():
	# remove the over
	rock.material_override = null

	# give the exit hover signal
	player.hover_on_swappable_object = false

func handle_signal_for_position_swap():
	# verify that the signal execute to the good object
	if self.position == player.swappable_object_position:
		swap_position(player.position, self.get_position())
		magic.emitting = true
		magic_timer.start()
	
func swap_position(player_position, object_position):
	# change position
	self.set_position(player_position)
	player.set_position(object_position)
  
	FMODRuntime.play_one_shot_path("event:/SFX/Swap/Swap")

# Cooldown timer timeout stop the particules
func _on_magic_timer_timeout():
	magic.emitting = false


func _on_rock_destruction_shape_destructed():
	print("CRAAASH")
