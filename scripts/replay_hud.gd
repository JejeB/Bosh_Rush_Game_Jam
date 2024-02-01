extends Control

@onready var player : CharacterBody3D = $"../Player"
@onready var boss : CharacterBody3D = $"../Boss"
@onready var replay_label : Label = $VBoxContainer/ReplayLabel
@onready var game_hud : CanvasLayer = $"../GameHud"

func _ready():
	# connect signal when boss die
	boss.connect("boss_dead", handle_death_signal)
	# connect signal when player die
	player.connect("player_dead", handle_death_signal)

func handle_death_signal(result):
	# ensure nobody can do actions
	boss.game_state = false
	player.game_state = false
	
	# hide current hud
	game_hud.hide()
	
	#display new hud
	replay_label.text = result
	toggle_hud(true)

func toggle_hud(hud_boolean) -> void:
	self.visible = hud_boolean

# all the replay 
func reset_scene() -> void:
	get_tree().reload_current_scene()

func _on_texture_button_button_down():
	reset_scene()
	FMODRuntime.play_one_shot_path("event:/SFX/UI/UIClick")
