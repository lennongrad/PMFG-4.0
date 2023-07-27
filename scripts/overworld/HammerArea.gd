extends Area3D

var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play():
	timer = 10

func _process(_delta):
	if timer > 0:
		$Particles.emitting = true
		timer -= 1
	else:
		$Particles.emitting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
