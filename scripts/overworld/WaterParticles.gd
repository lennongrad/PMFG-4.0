extends GPUParticles3D

var timer = 0
var circle_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play():
	timer = 5
	circle_timer = 2

func _process(_delta):
	if timer > 0:
		emitting = true
		timer -= 1
	else:
		emitting = false
	
	if circle_timer > 0:
		if has_node("Circles"):
			$Circles.emitting = true
		circle_timer -= 1
	else:
		if has_node("Circles"):
			$Circles.emitting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
