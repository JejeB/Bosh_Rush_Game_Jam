extends CharacterBody3D

signal hp_changed
signal state_changed

enum State { MELLE_ATTACK, CHASE, AIMING_PLAYER,JUMPING,PREPARE_JUMP}

@export_subgroup("Properties")
@export var movement_speed = 250
@export var max_hp: int = 1000
@export var melee_range: int = 5
@export var jump_range: int = 10

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var aiming:Vector3
var previously_floored = false

var hp: int
@export var target: Node
@export var bomb:Node

@onready var particles_trail = $ParticlesTrail
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer
@onready var attackhitbox1 = $AttackHitbox/MeshInstance3D/Area3D
@onready var attackhitbox1Node = $AttackHitbox
@onready var attackhitboxAnim = $AttackHitbox/AnimationPlayer
@onready var timer = $Timer
@onready var boss_state: int = State.CHASE

# Functions
func _ready():
	hp = max_hp
	back_to_default_state()

func _physics_process(delta):
	# Handle functions
	handle_gravity(delta)
	choose_action(delta)	
	handle_movement(delta)

func choose_action(delta):
	
	if boss_state == State.CHASE:
		var distance:int = target.global_position.distance_to(self.global_position)
		if distance < melee_range:
			start_melee_attack()
		elif distance > jump_range:
			start_jump_attack()
		else :
			chase_player()
	elif boss_state == State.AIMING_PLAYER:
		look_at(target.position,Vector3.UP,true)
	elif boss_state == State.JUMPING:
		var distance:int = aiming.distance_to(self.global_position)
		if distance < melee_range:
			start_melee_attack()
		else:
			jump_on_player()
	elif boss_state == State.PREPARE_JUMP:
		look_at(aiming,Vector3.UP,true)
	
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


func start_melee_attack():
	movement_velocity = Vector3.ZERO
	attackhitbox1Node.visible = true
	attackhitboxAnim.play("attack")
	state(State.MELLE_ATTACK)

func start_jump_attack():
	movement_velocity = Vector3.ZERO
	animation.play("static")
	state(State.AIMING_PLAYER)
	start_timer_for(1.5)
	
func chase_player():
	animation.play("walk", 0.5)
	particles_trail.emitting = true
	movement_velocity = position.direction_to(target.position) * movement_speed

func jump_on_player():
	animation.play("walk", 3)
	particles_trail.emitting = true
	movement_velocity = position.direction_to(aiming) * movement_speed * 50

func back_to_default_state():
	state(State.CHASE)
	attackhitbox1Node.visible = false
	attackhitboxAnim.stop()
	animation.play("idle")
	
func melee_attack():
	for body in attackhitbox1.get_overlapping_bodies():
		if body==target:
			target.hurt()
		if body.get_name()=="RockHitbox":
			update_hp(-100)

func handle_gravity(delta):
	gravity += 25 * delta
	if gravity > 0 and is_on_floor():
		gravity = 0

func update_hp(value:int):
	hp=hp+value
	hp_changed.emit((float(hp)/float(max_hp))*100)


func _on_timer_timeout():
	if boss_state == State.AIMING_PLAYER:
		aiming = target.position
		state(State.PREPARE_JUMP)
		start_timer_for(0.5)
	elif boss_state == State.PREPARE_JUMP:
		state(State.JUMPING)

func start_timer_for(value:float):
	timer.set_wait_time(value)
	timer.start()
	
func state(value:int):
	boss_state = value
	print(State.keys()[value])
	state_changed.emit(State.keys()[value])
