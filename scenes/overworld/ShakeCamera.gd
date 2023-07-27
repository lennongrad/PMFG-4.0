extends Camera3D

@onready var translation_default = position.x
var timer = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shake():
	timer = 0

func _process(_delta):
	if timer < 7.5:
		timer += .5
		position.x = translation_default + sin(floor(timer) * 2)
	else:
		position.x = translation_default
