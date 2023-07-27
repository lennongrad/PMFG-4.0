extends Marker3D

var isPlaying = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = $Timer.connect("timeout", Callable(self, "pause"))
	pause()

func play():
	$Particles.emitting = true
	$Particles2.emitting = true
	isPlaying = true
	$Timer.start()

func pause(): 
	isPlaying = false
	$Particles.emitting = false
	$Particles2.emitting = false
