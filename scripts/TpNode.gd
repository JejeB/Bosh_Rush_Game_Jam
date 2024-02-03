extends Node3D

@export var dialog:Array = ["Young warrior, the time has come.\nWe need your powers to save our land from destruction at the claws of\nTezcatlipoca, the Smoking Mirror.\nQuickly! I will take you to his lair. Good Luck!"]

@onready var boss_hud = $"../GameHud/Boss"
@onready var dialog_hud = $"../DialogHud"
@onready var label_container = $"../DialogHud/CenterContainer"
@onready var dialog_label = $"../DialogHud/CenterContainer/DialogLabel"
@onready var main_scene = "res://scenes/main.tscn"

var state_dialog = false

# Called when the node enters the scene tree for the first time.
func _ready():
	boss_hud.hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("click_gauche") and state_dialog:
		get_tree().change_scene_to_file(main_scene)
		FMODRuntime.play_one_shot_path("event:/SFX/UI/TutGuy")


func _on_area_3d_body_entered(body):
	dialog_label.text = dialog[0]
	dialog_hud.show()
	label_container.show()
	state_dialog = true
	
