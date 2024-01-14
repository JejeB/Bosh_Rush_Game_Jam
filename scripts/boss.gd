extends CharacterBody3D

signal hp_changed

enum State { IDLE, MELLE_ATTACK}

@export_subgroup("Properties")
@export var movement_speed = 250
@export var max_hp: int = 1000

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0


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
@onready var boss_state: int = State.IDLE

# Functions
func _ready():
	hp = max_hp
	attackhitbox1Node.visible = false

func _physics_process(delta):
	# Handle functions
	handle_gravity(delta)
	handle_effects()
	melleAttack()
	
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
	
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
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
		else:
			animation.play("idle", 0.5)
	

func melleAttack():
	if target.global_position.distance_to(self.global_position) < 3 && boss_state== State.IDLE:
			attackhitbox1Node.visible = true
			attackhitboxAnim.play("attack")
			boss_state = State.MELLE_ATTACK


func back_idle():
	boss_state = State.IDLE
	attackhitbox1Node.visible = false
	attackhitboxAnim.stop()
	
func hurt():
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
