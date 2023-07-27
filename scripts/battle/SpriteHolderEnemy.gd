extends Marker3D

var active = true
var fallTimer = 0
var dodge_timer = 00

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = (randi() % 10 + 1) * .05
	$Timer.start()
	deactivate()

func dodge():
	dodge_timer = 20

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
		dodge_timer -= 1
		$AnimatedSprite3D.position.x += (.5 - $AnimatedSprite3D.position.x) * .1
		$AnimatedSprite3D.position.y += (.3 - $AnimatedSprite3D.position.y) * .1
	else:
		$AnimatedSprite3D.position.x += (0 - $AnimatedSprite3D.position.x) * .1
		$AnimatedSprite3D.position.y += (.16 - $AnimatedSprite3D.position.y) * .1
	if has_node("Balloons"):
		$Balloons.position = $AnimatedSprite3D.position

func _on_Timer_timeout():
	activate()
