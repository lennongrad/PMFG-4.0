extends Camera3D

var timer = 0
@onready var base_translation = position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shake():
	timer = 10

func _process(delta):
	if timer > 0:
		position.x = base_translation.x + sin(timer) * .2
		timer -= delta * 100
	else:
		position.x = base_translation.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
