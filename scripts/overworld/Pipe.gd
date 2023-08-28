extends Node3D

signal finished_growing
signal finished_shrinking

var timer = -30
var direction = 0
var has_finished = false
var has_finished_shrinking = false

func _process(_delta):
	timer += direction * .75
	
	if timer > 30 and timer < 32 and not has_finished:
		$SFX.play("Expand", false)
	
	if timer < 55:
		if timer > 10:
			$Pipe.scale = Vector3(16,16,18) * (.01 + min(pow(float(timer) / 45, 8), 1))
		if not has_finished:
			$Base.scale = Vector3(1,1,1) * (min(1, float(timer) / 15) + .1)

	if timer > 80 and not has_finished and direction == 1:
		direction = 0
		emit_signal("finished_growing")
		has_finished = true

	if timer < 0 and not has_finished_shrinking and direction == -1:
		direction = 0
		emit_signal("finished_shrinking")
		has_finished_shrinking = true

func start():
	direction = 1

func end():
	if direction == 0:
		direction = -1
		timer = 50
