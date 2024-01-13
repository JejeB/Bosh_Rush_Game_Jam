extends Object

class_name Life

signal life_changed

var _max_hp: int
var _hp: int
# Called when the node enters the scene tree for the first time.
func _init(max:int):
	_max_hp=max
	_hp = max

func update_hp(value:int):
	_hp=_hp+value
	life_changed.emit((_hp/_max_hp)*100)

func get_hp():
	return _hp
