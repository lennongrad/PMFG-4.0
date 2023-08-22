extends Sprite3D

var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_text(text):
	$Label.text = text

func reactivate():
	timer = 0
	position.y = .4
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.set_position($"../../Camera3D".unproject_position(get_global_transform().origin) - Vector2(40, 60))
	
	timer += 1
	if timer < 35:
		$Particles.emitting = true
		position.y += (.75 - position.y) * .05
		$Label.modulate.a += (1 - $Label.modulate.a) * .1
	elif timer < 50:
		$Particles.emitting = false
		$Label.modulate.a -= $Label.modulate.a * .1
	else:
		visible = false
		$Label.modulate.a = 0
