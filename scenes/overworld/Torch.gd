extends MeshInstance3D

var timer1 = 0
var timer2 = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer1 += delta * (randi() % 10)
	$OmniLight2.omni_range = abs(cos(timer1 / 5)) * .1 + 1
	
	timer2 += delta * (randi() % 10)
	$OmniLight2.light_energy = abs(cos(timer2 * .5) * sin(timer1 * .2)) * 1.5 + .5
