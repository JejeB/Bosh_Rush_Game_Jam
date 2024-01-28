extends CanvasLayer

@export var cooldown_color : Color = "0073f8f7"

@onready var boss_life_bar = $Boss/VBoxContainer/LifeBarHBox/BossLifeBar
@onready var player_life_bar = $Player/LifeBarHBox/PlayerLifeBar
@onready var blood_texture: TextureRect = $VFX/BloodTexture
@onready var blood_timer = $VFX/BloodTime
@onready var swappable_info: TextureRect = $Player/LifeBarHBox/SwappableInfo

func _on_player_hp_changed(ratio):
	player_life_bar.set_value(ratio)
	blood_texture.visible = true
	blood_timer.start()

func _on_blood_time_timeout():
	blood_texture.visible = false	

func _on_boss_hp_changed(ratio):
	boss_life_bar.set_value(ratio)

func _on_player_spell_changed(spell_name):
	
	if spell_name == 'Cooldown': 
		swappable_info.set_modulate(cooldown_color)
	else:
		swappable_info.modulate = Color(1,1,1)



