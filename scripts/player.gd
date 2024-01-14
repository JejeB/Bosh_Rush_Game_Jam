extends CharacterBody3D

signal hp_changed
signal spell_changed
signal swappositon

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var max_hp = 100

enum Swap_State {MOVEMENT, SWAP, COOLDOWN}

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true
var swap_state_mode = Swap_State.MOVEMENT
var hover_on_swappable_object : bool = false
var swappable_object_position : Vector3 = Vector3.ZERO
var spell_range : int = 10

var coins = 0

var target = Vector3.ZERO
 
var hp: int
@onready var particles_trail = $ParticlesTrail
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer
@onready var swap_cooldown_timer = $SwapCooldownTimer
@onready var spell_indicator = $SpellIndicator

# Functions

func _ready():
	hp = max_hp

func _physics_process(delta):
	
	# Handle functions
	handle_action(delta)
	handle_controls(delta)
	handle_gravity(delta)
	
	handle_effects()
	
	# Movement
	var applied_velocity: Vector3
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
	
	# Falling/respawning
	if position.y < -10:
		get_tree().reload_current_scene()
	
	# Animation for scale (jumping and landing)
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	
	# Animation when landing
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		
	previously_floored = is_on_floor()

# Handle animation(s)
func handle_effects():
	particles_trail.emitting = false
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			animation.play("walk", 0.5)
			particles_trail.emitting = true
			FMODRuntime.play_one_shot_path("event:/SFX/Hero/HeroFootsteps")
		else:
			animation.play("idle", 0.5)
			FMODRuntime.play_one_shot_path("event:/SFX/Hero/HeroFootstepsStop")

# old function to Handle movement input with keyboard
func handle_controls(delta):
	
	# Movement
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	
	movement_velocity = input * movement_speed * delta
	
# Handle gravity
func handle_gravity(delta):
	gravity += 25 * delta
	
	if gravity > 0 and is_on_floor():
		gravity = 0

# function to handle the deplacement of the player using mouse
func handle_point_and_click(delta):
	if target:
		var direction = global_position.direction_to(target)
		movement_velocity = direction * movement_speed * delta
		
		if transform.origin.distance_to(target) < .5:
			target = Vector3.ZERO
			movement_velocity = Vector3.ZERO

# Handle the action when you press your spell or sword
func handle_action(delta):
	# if the swap button is pressed and the player is not in cooldown state attribute swap mode
	if Input.is_action_just_released("swap_button") :
		spell_indicator.visible = false
		
		if hover_on_swappable_object and swap_state_mode != Swap_State.COOLDOWN:
			swap_state_mode = Swap_State.SWAP
			# swap position
			emit_signal("swappositon")
			
			# Begin The Cooldown the spell for the player
			swap_state_mode = Swap_State.COOLDOWN
			swap_cooldown_timer.start()
			# emit signal for the hud
			emit_signal("spell_changed", "Cooldown")
	
	if Input.is_action_just_pressed("swap_button"):
		spell_indicator.visible = true
		spell_indicator.scale.x = spell_range
		spell_indicator.scale.z = spell_range
		
	# Reinit the movement mode when cooldown 
	#if Input.is_action_just_pressed("click_gauche") and swap_state_mode != Swap_State.COOLDOWN:
	#	swap_state_mode = Swap_State.MOVEMENT

# when the timer cooldown is finish reset the swap_state_mode
func _on_swap_cooldown_timer_timeout():
	swap_state_mode = Swap_State.MOVEMENT
	# hud update
	emit_signal("spell_changed", "Swap Ready")

func update_hp(value:int):
	hp=hp+value
	hp_changed.emit((float(hp)/float(max_hp))*100)

func hurt():
	update_hp(-10)
