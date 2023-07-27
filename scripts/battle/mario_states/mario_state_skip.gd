extends State

class_name SkipState

var skipTimer = 0

func _ready():
	hero.get_node("Sprite2D").play("Skip")
	hero.get_node("Exclamation").visible = true

func _process(_delta):
	skipTimer += 1
	if skipTimer > 50:
		hero.get_node("Exclamation").visible = false
		hero.progress_attack()

func tween_completed():
	pass
