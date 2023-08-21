extends State

class_name WalktoState

func _ready():
	hero.focus_camera(1);
	if hero.in_water():
		hero.get_node("Sprite2D").play("Swim")
	else:
		hero.get_node("Sprite2D").play("Walk")
	var distance = Vector3(hero.get_current_attack().walkto_distance, 0, 0)
	
	var enemyPosition = hero.front_position + Vector3(.6, 0, 0)
	if hero.target != null and  hero.get_current_attack().walkto_distance != 0:
		enemyPosition = hero.target.position - distance
		enemyPosition.y = 0
	else:
		enemyPosition = distance
	
	self.interpolate_property(hero, "position", enemyPosition, .5)
	#	hero.position, enemyPosition, .5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
func tween_completed():
	hero.progress_attack()

func _physics_process(_delta):
	pass
