extends Node3D

@export_group("Properties")
@export var target: Node

@export_group("Placement")
@export var distance = 10
@export var height = 10

@export_group("Freeze Properties")
@export var freeze_time : float = 0.5
@export var traveling_time : float = 0.2

@export_group("Shake Properties")
@export var trauma_reduction_rate : float = 1.0
@export var noise : FastNoiseLite
@export var noise_speed : float =  50.0
@export var max_x : float = 10.0
@export var max_y : float = 10.0
@export var max_z : float = 5.0
@export var trauma_amount : float = 0.6
@export var shake_time : float = 0.2

enum Camera_State {FOLLOW, FREEZE, WAIT, TRANSITION, SHAKING}

var camera_rotation:Vector3
var last_seen_position:Vector3
var camera_freeze: Camera_State = Camera_State.FOLLOW

var trauma = 0.0
var time = 0.0

@onready var camera = $Camera
@onready var camera_freeze_timer: Timer = $Camera/CameraFreezeTimer

# Freeze properties
@onready var initial_rotation: Vector3 = self.rotation_degrees
@onready var camera_shake_timer: Timer = $Camera/ShakeTimer


func _ready():
	camera_rotation = rotation_degrees # Initial rotation
	camera_freeze_timer.wait_time = freeze_time
	camera_shake_timer.wait_time = shake_time

# every frame calculation
func _physics_process(delta):
	camera_calculus(self.camera_freeze)
	camera_shaking(delta, self.camera_freeze)

# all the calculus depending on the situation
func camera_calculus(camera_freeze):
	if camera_freeze == Camera_State.FOLLOW:
		camera.look_at(target.position)
		self.position = target.position
		camera.position = Vector3(0, height, distance)
	
	elif camera_freeze == Camera_State.TRANSITION:
		camera_transition(self.last_seen_position, target.position)
		
	elif camera_freeze == Camera_State.FREEZE:
		camera.look_at(self.last_seen_position)
		self.position = self.last_seen_position
		camera.position = Vector3(0, height, distance)
	
func camera_transition(from_position, to_position: Vector3):
	self.camera_freeze = Camera_State.WAIT
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	#ween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", to_position, traveling_time).from(from_position)
	
	tween.play()
	
	await tween.finished
	
	self.camera_freeze = Camera_State.FOLLOW

# When swapped the camera stay at the last player position
func _on_player_swap_positon():
	# fix the player position
	self.last_seen_position = target.position
	self.camera_freeze = Camera_State.FREEZE
	
	# start timer to defrooze camera
	camera_freeze_timer.start()

# Defrooze camera
func _on_camera_freeze_timer_timeout():
	self.camera_freeze = Camera_State.TRANSITION

# Shake Camera
func _on_boss_hp_changed(value):
	self.camera_freeze = Camera_State.SHAKING
	add_trauma(trauma_amount)
	camera_shake_timer.start()

func camera_shaking(delta, camera_freeze):
	if camera_freeze == Camera_State.SHAKING:
		time += delta
		trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
		
		self.rotation_degrees.x =  initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
		self.rotation_degrees.y =  initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
		self.rotation_degrees.z =  initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)

func add_trauma(trauma_amount : float):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)

func _on_shake_timer_timeout():
	self.camera_freeze = Camera_State.FOLLOW
