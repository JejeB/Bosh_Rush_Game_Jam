extends Node3D

@onready var bush_object: StaticBody3D = $BushObject
@onready var activation_area: Area3D = $ActivationArea

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_activation_area_body_entered(body):
	print(body.get_name())


func _on_activation_area_area_entered(area):
	print(area.get_name())
