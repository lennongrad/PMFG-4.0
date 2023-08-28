extends State

class_name IdleState

var finishedTween = true

func _ready():
	hero.get_node("Sprite2D").play("Rest")

func _process(_delta):
	if hero.animation_wait > 0:
		hero.position = hero.get_home_position() + Vector3(cos(randi()) * .05,0,0)
		return
	
	if not finishedTween:
		if hero.in_water():
			hero.get_node("Sprite2D").play("Swim")
		else:
			sfx.play("Footsteps", false)
			hero.get_node("Sprite2D").play("Walk")
		return
	
	sfx.stop("Footsteps")
	if hero.in_water():
		hero.get_node("Circles").visible = true
	else:
		hero.get_node("Circles").visible = false
	
	var differenceFromHome = hero.get_home_position() - hero.position
	if differenceFromHome.length() > .05:
		interpolate_property(hero, "position", hero.get_home_position(), .5)
		finishedTween = false
	elif hero.is_idle and hero.is_selected_teammate:
		hero.get_node("Sprite2D").play("Think")
	else:
		if hero.in_water():
			hero.get_node("Sprite2D").play("Swim")
		else:
			hero.get_node("Sprite2D").play("Rest")
		if not hero.first_strike_active:
			hero.position = hero.get_home_position()

func tween_completed():
	finishedTween = true
