extends Node3D

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


func _on_area_3d_body_entered(body):
	dialog_label.text = "Young warrior, the time has come.\n You have passed the rite of initiation with honor and strength.\n You have proven yourself worthy to face the great god,\n Tezcatlipoca, the Smoking Mirror, the Patron of mirrors, 
hidden truths, and illusions."
	dialog_hud.show()
	label_container.show()
	state_dialog = true
	
