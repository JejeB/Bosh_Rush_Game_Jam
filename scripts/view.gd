extends Node3D

@export_group("Properties")
@export var target: Node

@export_group("Placement")
@export var distance = 10
@export var height = 10

var camera_rotation:Vector3

@onready var camera = $Camera

func _ready():
	
	camera_rotation = rotation_degrees # Initial rotation
	
	pass

func _physics_process(delta):
	camera.look_at(target.position)
	self.position = target.position
	camera.position = Vector3(0, height, distance)
	pass

