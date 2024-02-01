extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_event = InputEventMouseMotion.new()
	mouse_event.position = get_viewport().get_mouse_position()
	Input.parse_input_event(mouse_event)
