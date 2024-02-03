extends Area3D

@export var HOVER_MATERIAL:Material
@export var ACTIVATED_MATERIAL:Material
@export var gate_mesh:StaticBody3D
@export var dialog:Array = ["Welcome, noble Aztec fighter! \nUse your powers to open the gate! \nPress <SPACEBAR> while highlighting your target with the <MOUSE>"]
@export var blink_time : float = 0.5

@onready var mesh = $HexSand
@onready var timer = $Timer
@onready var dialog_hud = $"../../DialogHud"
@onready var dialog_label = $"../../DialogHud/CenterContainer/DialogLabel"
@onready var control_help = $"../../DialogHud/CenterContainer2/TextureRect"
@onready var dialog_center = $"../../DialogHud/CenterContainer"


var hollow_state = false
var gate_state = false
var dialog_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	dialog_label.text = dialog[dialog_count]
	dialog_hud.show()
	dialog_count += 1
	timer.wait_time = blink_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if Input.is_action_just_pressed("click_gauche") and dialog_count == len(dialog):
		control_help.show()
		dialog_center.hide()
		
	if Input.is_action_just_pressed("click_gauche") and dialog_count < len(dialog):
		dialog_hud.hide()
		dialog_label.text = dialog[dialog_count]
		dialog_hud.show()
		dialog_count += 1
		FMODRuntime.play_one_shot_path("event:/SFX/UI/UIClick")
		
	if Input.is_action_just_pressed("click_gauche") and gate_state:
		control_help.hide()
		dialog_hud.hide()

func _on_timer_timeout():
	hollow_state = !hollow_state
	
	if hollow_state:
		mesh.set_surface_override_material(0,HOVER_MATERIAL)
	else :
		mesh.set_surface_override_material(0,null)

func _on_area_entered(area):
	if area.get_name() == "StunCollision" and !gate_state:
		mesh.set_surface_override_material(0,ACTIVATED_MATERIAL)
		
		gate_mesh.position.y = gate_mesh.position.y - 2
		timer.stop()
		gate_state = true
		dialog_label.text = "Excellent! You opened the door! \nNow, use your abilities to cross the chasum."
		dialog_center.show()
