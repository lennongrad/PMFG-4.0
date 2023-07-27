extends Marker3D

var timer = 0
var popping = false
var depressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func pop():
	if popping:
		return
	$Balloons.play("pop")
	popping = true

func depress():
	depressed = true

func unpress():
	depressed = false

func _physics_process(_delta):
	#translation = $"../Sprite".translation - Vector3(0,0,.1)
	
	if popping:
		timer += 1
		if timer > 30:
			visible = false
	
	if depressed:
		scale.y += (.6 - scale.y) * .3
	else:
		scale.y += (1 - scale.y) * .3
