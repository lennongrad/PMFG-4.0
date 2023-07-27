extends Node3D

var shockwaveCounter = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func restart_shockwave(center):
	shockwaveCounter = 0
	$Floor.mesh.material.set_shader_parameter("center", center)

func _process(delta):
	shockwaveCounter += delta
	#$Floor.mesh.material.set_shader_param("size", shockwaveCounter)
