extends CharacterBody3D

signal hp_changed
signal state_changed
signal boss_dead

enum State { MELLE_ATTACK, CHASE, AIMING_PLAYER,JUMPING,PREPARE_JUMP,STUN}


@export_subgroup("Properties")
## Speed deplacement of the boss
@export var movement_speed = 250
## Health point of the boss
@export var max_hp: int = 1000
@export var target: Node

@export_subgroup("Melee Attack")
## Range of the melee attack
@export var MELEE_RANGE: float = 2

@export_subgroup("JumpAttack")
## The range that trigger the jump action if the player is over
@export var JUMPING_RANGE: int = 10
## The time before the jump when the boss is targeting the player in sec
@export var AIMING_TIME:float = 1.5
## Time elasped between 2 jumps in sec
@export var JUMP_COOLDOWN:float = 5
## The distance of the dash done
@export var JUMPING_DISTANCE:float = 20.

var JUMP_SPEED:int = 50

@export_subgroup("STUNT")
## Time of the stun in sec
@export var STUN_TIME:float = 2

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0
var jump_ready = true

var jump_start_point:Vector3
var previously_floored = false

var hp: int
var game_state: bool = true

@onready var particles_trail = $ParticlesTrail
@onready var model = $dragon6
@onready var animation = $dragon6/AnimationPlayer
@onready var blood = $Blood
@onready var jump_path = $JumpPath

@onready var attacktime = $AttackTime
@onready var timer = $Timer
@onready var boss_state: int = State.CHASE

var last_pos:Vector3 = Vector3.ZERO
var stuck_count:int = 0

var zone_attack_scene = preload("res://zone_attack.tscn")
var zone_attack
var zone_attack_cut_scene :bool = true

var blink_effect:float = 0.

# Functions
func _ready():
	hp = max_hp
	back_to_default_state()
	jump_path.mesh.set_height(JUMPING_DISTANCE)
	jump_path.position = Vector3(0,0.5,JUMPING_DISTANCE/2)

func _physics_process(delta):
	# Handle functions
	if game_state:
		handle_hp()
		handle_gravity(delta)
		choose_action()
		handle_movement(delta)
		if boss_state == State.STUN:
			blink(delta)
	

func choose_action():
	if boss_state == State.CHASE:
		var distance:float = target.global_position.distance_to(self.global_position)
		if distance < MELEE_RANGE or isStuck(0.01):
			start_melee_attack()
		elif distance > JUMPING_RANGE and jump_ready:
			start_jump_attack()
		else :
			chase_player()
	elif boss_state == State.JUMPING:
		var distance:float = jump_start_point.distance_to(self.global_position)
		jump_on_player()
		if distance > JUMPING_DISTANCE or isStuck(0.01):
			movement_velocity = Vector3.ZERO
			velocity = Vector3.ZERO
			back_to_default_state()
	elif boss_state == State.AIMING_PLAYER:
		jump_path.visible = true
	


# ---JUMP---
func start_jump_attack():
	movement_velocity = Vector3.ZERO
	animation.play("boss idle1")
	state(State.AIMING_PLAYER)
	start_timer_for(AIMING_TIME)
	start_attack_timer_for(JUMP_COOLDOWN)
	jump_ready = false
	init_zone_attack()
	FMODRuntime.play_one_shot_path("event:/SFX/Boss/DeathRay", get_global_transform())
	
	
func jump_on_player():
	jump_path.visible = false
	animation.play("boss walk", 3)
	particles_trail.emitting = true
	movement_velocity = get_global_transform().basis.z * movement_speed * JUMP_SPEED
	

# ---MELEE ATTACK---
func start_melee_attack():
	animation.play(("boss idle1"))
	state(State.MELLE_ATTACK)
	start_timer_for(1)
	movement_velocity = Vector3.ZERO
	init_zone_attack()
	pass


# ---STUN---
func start_stun():
	movement_velocity = Vector3.ZERO
	velocity = Vector3.ZERO
	state(State.STUN)
	animation.play("boss idle1")
	start_timer_for(STUN_TIME)
	free_zone_attack()
	FMODRuntime.play_one_shot_path("event:/SFX/Boss/TakeDamage", get_global_transform())
	
func blink(delta):
	if blink_effect > 0.15:
		blink_effect =0.
		if model.visible:
			model.visible = false
		else:
			model.visible = true
	blink_effect+=delta
	
# ---CHASE PLAYER---
func chase_player():
	animation.play("boss walk", 0.5)
	particles_trail.emitting = true
	movement_velocity = position.direction_to(target.position) * movement_speed


# ---HP---	
func handle_hp():
	if hp <= 0:
		game_state = false
		target.game_state = false
		emit_signal("boss_dead", "YOU WIN")

func hurted(damage:int):
	update_hp(damage)
	blood.emitting = true
	
func update_hp(value:int):
	hp=hp+value
	hp_changed.emit((float(hp)/float(max_hp))*100)


# -- TIMERS---
func _on_timer_timeout():
	timer.stop()
	if boss_state == State.AIMING_PLAYER:
		jump_start_point = position
		state(State.JUMPING)
		FMODRuntime.play_one_shot_path("event:/SFX/Boss/BossRush", get_global_transform())
	else :
		back_to_default_state()

func start_timer_for(value:float):
	timer.set_wait_time(value)
	timer.start()
	
func start_attack_timer_for(value:float):
	attacktime.set_wait_time(value)
	attacktime.start()
	
func _on_attack_time_timeout():
	if !jump_ready:
		jump_ready = true
	

# ---MOVEMENT---
func handle_movement(delta):
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
	
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
	previously_floored = is_on_floor()

func handle_gravity(delta):
	gravity += 25 * delta
	if gravity > 0 and is_on_floor():
		gravity = 0
# ---UTIL---
func state(value:int):
	boss_state = value
	state_changed.emit(State.keys()[value])

func back_to_default_state():
	state(State.CHASE)
	#animation.play("idle")
	free_zone_attack()
	model.visible = true

# If the boss is 3 time a the same position we assume that he's stuck	
func isStuck(epsilon:float):
	if position.distance_to(last_pos) < epsilon:
		stuck_count+=1
	last_pos = position
	if stuck_count >=10:
		stuck_count=0
		return true
	else:
		return false

# --- ZONE Attack---
func init_zone_attack():
	if zone_attack_cut_scene :
		zone_attack = zone_attack_scene.instantiate()
		zone_attack.set_scale(Vector3(1,1,1)*MELEE_RANGE)
		add_child(zone_attack)
	
func free_zone_attack():
	if zone_attack!=null:
		zone_attack.queue_free()
