extends Node3D

@export var INITIAL_STONE_NUMBER:int = 50
@export var RESPAWN_TIMER:int = 60
@export var RESPAWN_NUMBER:int = 1
@export var player:Node

@onready var timer = $Timer

var max_size = 37
var swap_object_scene = preload("res://objects/swappable_object.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	timer.set_wait_time(RESPAWN_TIMER)
	timer.start(RESPAWN_NUMBER)

func respawn_rock(number:int):
	for i in range(0, number):
		var aSwap = swap_object_scene.instantiate()
		var position = Vector3(rng.randi_range(-max_size,max_size),0,rng.randi_range(-max_size,max_size))
		aSwap.init(position,player)
		add_child(aSwap)

func _on_player_player_initiated():
	respawn_rock(INITIAL_STONE_NUMBER)


func _on_timer_timeout():
	respawn_rock(RESPAWN_NUMBER)
