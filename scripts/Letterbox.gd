extends Control

var enabled = false

func toggle():
	enabled = not enabled

func _process(_delta):
	if enabled:
		modulate.a += (1 - modulate.a) * .1
	else:
		modulate.a -= modulate.a * .1
