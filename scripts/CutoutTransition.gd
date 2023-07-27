extends Control

var playing = 0
var counter = 0
var isPlaying = false

signal finishedSpinning

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	counter += .016 * playing 
	if playing == -1:
		counter -= .015
		if counter <= .25:
			playing = 0
			isPlaying = false
			emit_signal("finishedSpinning")
	if playing == 1:
		if counter > 2:
			playing = 0
			isPlaying = false
			emit_signal("finishedSpinning")
	$ColorRect.material.set_shader_parameter("TimerValue", counter)

func start_spinning():
	counter = .25
	playing = 1
	isPlaying = true
	
func spin_backwards():
	counter = 1.8
	playing = -1
	isPlaying = true
