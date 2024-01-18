extends Node3D

@export_group("Properties")
@export var target: Node

@export_group("Placement")
@export var distance = 10
@export var height = 10

@export_group("Freeze Properties")
@export var freeze_time : float = 0.5
@export var traveling_time : float = 0.2

enum Camera_State {FOLLOW, FREEZE, WAIT, TRANSITION}

var camera_rotation:Vector3
var last_seen_position:Vector3
var camera_freeze: Camera_State = Camera_State.FOLLOW

@onready var camera = $Camera
@onready var camera_freeze_timer: Timer = $Camera/CameraFreezeTimer

func _ready():
	camera_rotation = rotation_degrees # Initial rotation
	camera_freeze_timer.wait_time = freeze_time

# every frame calculation
func _physics_process(delta):
	camera_calculus(self.camera_freeze)

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
