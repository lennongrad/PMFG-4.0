extends TextureRect

var active = false
var down_timer = 0
var rotate_timer = 0

func set_active(p_active):
	active = p_active

func _process(_delta):
	if down_timer > 0 or not active:
		down_timer -= 1
		modulate.a += (-modulate.a) * .5
	else:
		modulate.a += (1 - modulate.a) * .5
	if Input.is_action_just_pressed("ui_accept"):
		down_timer = 10
	rotate_timer += 1
	rotation = cos(float(rotate_timer) / 10) * .5


func _on_BookText_text_started():
	set_active(true)
