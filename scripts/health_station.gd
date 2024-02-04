extends Area3D

@export var health_gain: int = 10

@onready var particules: GPUParticles3D = $MagicParticles
@onready var mesh: MeshInstance3D = $Grapes
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var one_time_pass = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(pos:Vector3):
	position = pos
	
func _on_body_entered(body : Node3D):
	if body.get_name() == 'Player' and one_time_pass:
		body.update_hp(health_gain)
		particules.emitting = true
		
		self.one_time_pass = false
		collision_shape.visible = false
		mesh.visible = false

func _on_magic_particles_finished():
	self.queue_free()
