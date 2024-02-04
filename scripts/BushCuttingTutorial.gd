extends Node3D

@export var dialog:Array = ["PRESS <Right Click> with the <MOUSE> to use your SWORD"]

@onready var bush_object: StaticBody3D = $BushObject
@onready var activation_area: Area3D = $ActivationArea
@onready var dialog_hud = $"../DialogHud"
@onready var dialog_label = $"../DialogHud/CenterContainer/DialogLabel"
@onready var dialog_center = $"../DialogHud/CenterContainer"
@onready var cut_particles = $CutParticles

var player_is_in_area = false
var player_cuted_bush = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("click_gauche") and player_is_in_area:
		dialog_center.hide()


func _on_activation_area_body_entered(body):
	if body.get_name() == 'Player' and !player_is_in_area:
		player_is_in_area = true
		dialog_label.text = dialog[0]
		dialog_center.show()
		dialog_hud.show()


func _on_activation_area_area_entered(area: Area3D):
	if area.is_in_group('player_sword') and !player_cuted_bush:
		player_cuted_bush = true
		bush_object.queue_free()
		cut_particles.emitting = true
