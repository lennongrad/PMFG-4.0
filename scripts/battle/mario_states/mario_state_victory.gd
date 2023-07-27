extends State

class_name VictoryState

var victoryCounter = 0
var final_timer = 0
var experience_timer = 0
var decrement_timer = 0

func _ready():
	if hero.is_selected_teammate:
		hero.focus_camera(2)

func _process(_delta):
	victoryCounter += 1
	if victoryCounter < 10:
		hero.get_node("Sprite2D").play("Walk")
	elif victoryCounter < 20:
		hero.get_node("Sprite2D").rotation_degrees.y = victoryCounter * 32
	elif victoryCounter < 40:
		hero.get_node("Sprite2D").rotation_degrees.y = 0
		if hero.is_partner:
			hero.get_node("Sprite2D").play("Victory")
		else:
			hero.get_node("Sprite2D").play("FingerWag")
	else:
		if hero.get_experience_waiting() > 0:
			decrement_timer += 1
			if not hero.is_partner:
				hero.get_node("..").decrement_experience(decrement_timer % 2 == 0)
		elif experience_timer < 20:
			experience_timer += 1
			if not hero.is_partner:
				hero.get_node("Sprite2D").play("Blink")
		else:
			if hero.check_for_level_ups():
				hero.get_node("Sprite2D").play("Think")
			else:
				final_timer += 1
				if final_timer == 1 and hero.is_selected_teammate:
					hero.focus_camera(2)
				if final_timer == 1:
					hero.get_node("Sprite2D").play("Victory")
				if final_timer == 70:
					hero.get_node("Sprite2D").play("Walk")
					velocity.x = 1
					hero.is_victory_posing = false

func tween_completed():
	pass
