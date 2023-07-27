extends Sprite3D

var timer = 0
var last_visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if last_visible != visible:
		timer = 0
	last_visible = visible
	timer += 1
	if timer < 20 and visible:
		$Particles2.emitting = true
		$Particles3.emitting = true
		$Particles4.emitting = true
	else:
		$Particles2.emitting = false
		$Particles3.emitting = false
		$Particles4.emitting = false
