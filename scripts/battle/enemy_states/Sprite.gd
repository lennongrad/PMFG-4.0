extends Marker3D

var active = true
var fallTimer = 0
var dodge_timer = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = (randi() % 10 + 1) * .05
	$Timer.start()
	deactivate()

func dodge():
	dodge_timer = 100

func play(value):
	$AnimatedSprite3D.play(value)

func set_frames(frames):
	$AnimatedSprite3D.frames = frames

func set_flip_h(flip):
	$AnimatedSprite3D.flip_h = flip

func deactivate():
	active = false

func activate():
	active = true

func _process(_delta):
	if fallTimer > 0:
		position.y = 0
		$AnimatedSprite3D.position.y = .32
		rotation_degrees.x = -fallTimer
		$DustParticles.emitting = fallTimer > 40 and fallTimer < 60
	if dodge_timer > 0:
		$AnimatedSprite3D.position.x += (2 - $AnimatedSprite3D.position.x) * .1
	else:
		$AnimatedSprite3D.position.x += (1 - $AnimatedSprite3D.position.x) * .1

func _on_Timer_timeout():
	activate()
