extends Sprite3D

var timer = 0
var opacity = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_text(text):
	$Label.text = text

func reactivate():
	timer = 0
	visible = true
	opacity = .75
	position.y = .4
	scale = Vector3(.8, .8, .8)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.set_position($"../../Camera3D".unproject_position(get_global_transform().origin) - Vector2(40, 60))
	if visible:
		$Label.modulate.a += (.8 - $Label.modulate.a) * .025
	else:
		$Label.modulate.a -= $Label.modulate.a * .15
	
	timer += 1
	if timer < 35:
		scale.x += (1.1 - scale.x) * .05
		scale.y = scale.x
		position.y += (.5 - position.y) * .05
	elif timer < 60:
		opacity -= opacity * .025
	else:
		visible = false
