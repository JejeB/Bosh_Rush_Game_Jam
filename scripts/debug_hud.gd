extends Control

@onready var boss_state_label = $ListOfDebug/BossStateDebug/BossState
@onready var player_spell = $ListOfDebug/SwapStateDebug/SwapLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_hud"):
		self.visible = !self.visible


func _on_boss_state_changed(value):
	if boss_state_label:
		boss_state_label.text = value

func _on_player_spell_changed(spell_name):
	player_spell.text = spell_name
