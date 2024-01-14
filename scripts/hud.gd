extends CanvasLayer

@onready var boss_life_bar = $BossLife/LifeBar
@onready var player_life_bar = $Player/LifeBar
@onready var player_spell = $Player/SwapLabel
@onready var boss_state_label = $BossState

@onready var boss = $Boss

func _on_player_hp_changed(ratio):
	player_life_bar.set_value(ratio)

func _on_boss_hp_changed(ratio):
	boss_life_bar.set_value(ratio)

func _on_player_spell_changed(spell_name):
	player_spell.text = spell_name
	
func _on_boss_state_changed(value):
	if boss_state_label:
		boss_state_label.text = value
