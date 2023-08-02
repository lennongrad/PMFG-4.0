extends State

class_name RunState

var first_go = true

func _ready():
	hero.unfocus_camera();
	if hero.in_water():
		hero.get_node("Sprite2D").play("Swim")
	else:
		hero.get_node("Sprite2D").play("Walk")
	hero.get_node("Sprite2D").flip_h = false
	
	self.interpolate_property(hero, "position", hero.get_home_position() + Vector3(.3,0,0), 1.2)
	
func tween_completed():
	if first_go:
		first_go = false
		self.interpolate_property(hero, "position", hero.get_home_position() - Vector3(2,0,0), .75)
	else:
		hero.end_battle()
