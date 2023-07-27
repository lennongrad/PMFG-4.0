extends State

class_name IdleState

var finishedTween = true

func _ready():
	hero.get_node("Sprite2D").play("Rest")

func _process(_delta):
	if not finishedTween:
		if hero.in_water():
			hero.get_node("Sprite2D").play("Swim")
		else:
			hero.get_node("Sprite2D").play("Walk")
		return
	
	if hero.in_water():
		hero.get_node("Circles").visible = true
	else:
		hero.get_node("Circles").visible = false
	
	var differenceFromHome = hero.get_home_position() - hero.position
	if not hero.first_strike_active and differenceFromHome.length() > .05:
		interpolate_property(hero, "position", hero.get_home_position(), .5)
		finishedTween = false
	if hero.get_node("DodgeParticles").isPlaying:
		hero.get_node("Sprite2D").play("Guard")
		hero.position = hero.get_home_position() + Vector3(cos(randi()) * .05,0,0)
	elif hero.get_node("HurtParticles").isPlaying:
		hero.get_node("Sprite2D").play("Hurt")
		hero.position = hero.get_home_position() + Vector3(cos(randi()) * .05,0,0)
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
