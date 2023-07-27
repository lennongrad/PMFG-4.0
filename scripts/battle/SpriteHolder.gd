extends Marker3D

@export var frames: Resource
@export var flip_h: bool
@export var emitting: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play(value):
	$AnimatedSprite3D.play(value)

func _process(_delta):
	if $AnimatedSprite3D.frames != frames:
		$AnimatedSprite3D.frames = frames
	$AnimatedSprite3D.flip_h = flip_h
	$AnimatedSprite3D/Particles.emitting = emitting

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
