extends Control

@export var progress: int
var lights
var active

# Called when the node enters the scene tree for the first time.
func _ready():
	lights = [$Background/light1, $Background/light2, $Background/light3, $Background/bigLight]

func activate():
	visible = true
	active = true
	$Background.position.x = -1000

func deactivate():
	progress = 0
	active = false

func _process(_delta):
	var e = 0
	for i in lights:
		if e < progress:
			i.play("active")
		else:
			i.play("inactive")
		e+=1
	if active:
		$Background.position.x += -$Background.position.x * .1
	else:
		$Background.position.x += (2500 - $Background.position.x) * .1
