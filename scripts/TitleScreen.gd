extends Control

# this whole thing is done hastily to show the demo

signal done

var fade_timer = -1
var disabled = false

func disable():
	disabled = true

func _process(_delta):
	if fade_timer > -1 and fade_timer < 125:
		fade_timer += 1
		if fade_timer > 20:
			modulate.r -= modulate.r * .05
			modulate.g = modulate.r
			modulate.b = modulate.r
		$StartButton.visible = int(floor(fade_timer)) % 16 < 8
		if fade_timer == 120:
			emit_signal("done")
		if fade_timer == 125:
			visible = false
			disable()
	
	#$Cursor.position = 
	
	if not disabled:
		if Input.is_action_just_pressed("ui_accept"):
			fade_timer = 0
	else:
		visible = false

func _on_TextureButton_pressed():
	fade_timer = 0
