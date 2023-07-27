extends GPUParticles3D

var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func activate():
	timer = 0
	emitting = true

func _process(_delta):
	timer += 1
	if timer > 60:
		emitting = false
