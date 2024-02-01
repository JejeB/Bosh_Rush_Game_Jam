extends Node3D

@export var player: CharacterBody3D
@export var hover_range: int = 10
@export var HOVER_MATERIAL:Material
@export var HARD_MATERIAl:Material
@export var STANDAR_MATERIAl:Material
## Time when the rock is unbreakable after swap is sec
@export var POST_SWAP_TIME = 1

@onready var rock : MeshInstance3D = $rock/Cube_002
@onready var magic : GPUParticles3D = $MagicParticles
@onready var magic_timer : Timer = $MagicTimer

enum State {DESTROYABLE,HARD}
var state: int = State.DESTROYABLE

var current_material
var first_frame = true

func _process(_delta):
	if first_frame:
		connect_and_init()
		first_frame = false
	
func init(pos:Vector3,play:Node):
	position = pos
	player = play
	connect_and_init()
	

func connect_and_init():
	player.connect("swap_positon", handle_signal_for_position_swap)
	player.spell_range = hover_range
	current_material = STANDAR_MATERIAl

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
	rock.set_surface_override_material(1,current_material)
	magic.emitting = true
	start_timer_for(POST_SWAP_TIME)
	
# Cooldown timer timeout stop the particules
func _on_magic_timer_timeout():
	back_so_default()
	
func hurt(_position):
	if State.DESTROYABLE == state:
		print("[PLAY] Rock Destroy")
		queue_free()
	
func back_so_default():
	print("[PLAY] Rock stop being hard")
	state = State.DESTROYABLE
	magic.emitting = false
	current_material = STANDAR_MATERIAl
	rock.set_surface_override_material(1,current_material)
	
func start_timer_for(value:float):
	magic_timer.set_wait_time(value)
	magic_timer.start()


func _on_stun_collision_body_entered(body):
	if state == State.HARD and body.has_method("start_stun"):
		body.start_stun()

func _on_stun_collision_mouse_entered():
	rock.set_surface_override_material(1,HOVER_MATERIAL)
	FMODRuntime.play_one_shot_path("event:/SFX/Swap/SwapHover")
	player.hover_on_swappable_object = true
	player.swappable_object_position = self.get_position()


func _on_stun_collision_mouse_exited():
	rock.set_surface_override_material(1,current_material)
	player.hover_on_swappable_object = false
