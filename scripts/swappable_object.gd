extends Node3D

@export var player: CharacterBody3D
@export var hover_range: int = 10
@export var hover_color: Color = Color(0.92, 0.69, 0.13, 1.0)
@export var hard_color: Color = Color(0.92, 0.69, 0.13, 1.0)
@export var standar_color: Color = Color(1., 1., 1., 1.)
## Time when the rock is unbreakable after swap is sec
@export var POST_SWAP_TIME = 1

@onready var rock : MeshInstance3D = $rock
@onready var magic : GPUParticles3D = $MagicParticles
@onready var magic_timer : Timer = $MagicTimer

enum State {DESTROYABLE,HARD}
var state: int = State.DESTROYABLE
var HOVER_MATERIAL
var HARD_MATERIAl
var STANDAR_MATERIAl
var current_material

func _ready():
	# connect signal to swap position sended by player
	player.connect("swap_positon", handle_signal_for_position_swap)
	# give the range decided for the hover to the spell indicator
	player.spell_range = hover_range
	HOVER_MATERIAL = init_material(hover_color)
	HARD_MATERIAl = init_material(hard_color)
	STANDAR_MATERIAl = init_material(standar_color)
	current_material = STANDAR_MATERIAl
	rock.material_override = current_material
	
func init_material(c:Color):
	var m = StandardMaterial3D.new()
	m.albedo_color = c
	return m

# for the mouse moving
func input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and player.swap_state_mode == player.Swap_State.SWAP:

		var object_position = self.get_position()
		var player_position = player.position
		
		# change position
		self.set_position(player_position)
		player.set_position(object_position)
		
		# Cooldown the spell for the player
		player.swap_state_mode = player.Swap_State.COOLDOWN
		player.swap_cooldown_timer.start()


func _on_mouse_entered():
	
	var distance = player.global_position.distance_to(self.global_position)
	
	# range between the player and the object is in range
	if distance <= hover_range :
		rock.material_override = HOVER_MATERIAL
		FMODRuntime.play_one_shot_path("event:/SFX/Swap/SwapHover")
		
		# give the enter hover signal
		player.hover_on_swappable_object = true
		player.swappable_object_position = self.get_position()

func _on_mouse_exited():
	# remove the over
	rock.material_override = current_material

	# give the exit hover signal
	player.hover_on_swappable_object = false

func handle_signal_for_position_swap():
	# verify that the signal execute to the good object
	if self.position == player.swappable_object_position:
		swap_position(player.position, self.get_position())
	
func swap_position(player_position, object_position):
	# change position
	self.set_position(player_position)
	player.set_position(object_position)
	FMODRuntime.play_one_shot_path("event:/SFX/Swap/Swap")
	state  = State.HARD
	current_material = HARD_MATERIAl
	rock.material_override = current_material
	magic.emitting = true
	start_timer_for(POST_SWAP_TIME)
	
# Cooldown timer timeout stop the particules
func _on_magic_timer_timeout():
	back_so_default()
	
func hurt():
	if State.DESTROYABLE == state:
		print("Rock Destroy")
		queue_free()
	
func back_so_default():
	state = State.DESTROYABLE
	magic.emitting = false
	current_material = STANDAR_MATERIAl
	rock.material_override = current_material
	
func start_timer_for(value:float):
	magic_timer.set_wait_time(value)
	magic_timer.start()
