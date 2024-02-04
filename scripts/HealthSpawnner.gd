extends Node3D

@export var RESPAWN_TIMER:int = 60
@export var RESPAWN_NUMBER:int = 4

@onready var timer = $Timer

var max_size = 37
var swap_object_scene = preload("res://objects/health_station.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	respawn_rock(RESPAWN_NUMBER)
	timer.set_wait_time(RESPAWN_TIMER)
	timer.start()

func respawn_rock(number:int):
	for i in range(0, number):
		var aSwap = swap_object_scene.instantiate()
		var position = Vector3(rng.randi_range(-max_size,max_size),0,rng.randi_range(-max_size,max_size))
		aSwap.init(position)
		add_child(aSwap)

func _on_timer_timeout():
	respawn_rock(RESPAWN_NUMBER)
