extends State

class_name WalkbackState

func _ready():
	hero.unfocus_camera()
	if hero.in_water():
		hero.get_node("Sprite2D").play("Swim")
	else:
		hero.get_node("Sprite2D").play("Walk")
	hero.get_node("Sprite2D").flip_h = false
	
	interpolate_property(hero, "position", hero.get_home_position(), .5)
	
func tween_completed():
	hero.get_node("Sprite2D").flip_h = true
	hero.progress_attack()

func _physics_process(_delta):
	pass
