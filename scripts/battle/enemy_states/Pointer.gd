extends AnimatedSprite3D

var bobble = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	bobble += delta
	position.y = $"..".stats.height + .1 + sin(bobble * 4) * .025
