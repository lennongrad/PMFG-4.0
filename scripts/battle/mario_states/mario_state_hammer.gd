extends State

class_name HammerState

var holdDownCounter = 0
var holdingDown = false
var brokeHold = false
var animationCountdown = 0
var hammerType = "Iron"

func _ready(): 
	hero.focus_camera(1);
	hero.get_node("HammerLight").activate()
	hero.get_node("Sprite2D").play("HammerPreparation")
	hero.get_node("Hammer").play("Sideways")
	hero.get_node("Hammer").visible = true
	hero.get_node("Hammer").position = Vector3(0.11, 0.135, -0.01)
	hero.get_node("Hammer").rotation_degrees.z = 0
	#hero.tween.interpolate_property(hero, "rotation_degrees:x", 
	#	0, 0, .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	#hero.tween.start()

func finish():
	hero.get_node("Hammer").visible = false
	hero.progress_attack()

func _physics_process(_delta):
	if Input.is_action_pressed("ui_left") and not holdingDown and not brokeHold:
		holdingDown = true
	if not Input.is_action_pressed("ui_left") and holdingDown and holdDownCounter > 15:
		brokeHold = true 
	if holdingDown and not brokeHold:
		if holdDownCounter < 3:
			hero.get_node("Sprite2D").play("HammerPreparation2")
			hero.get_node("Hammer").position = Vector3(0.11, 0.16, -0.01)
			hero.get_node("Hammer").rotation_degrees.z = -5
		elif holdDownCounter < 10:
			hero.get_node("Sprite2D").play("HammerPreparation3")
			hero.get_node("Hammer").position = Vector3(0.11, 0.18, -0.01)
			hero.get_node("Hammer").rotation_degrees.z = -10
		elif holdDownCounter > 150:
			brokeHold = true 
		else:
			hero.get_node("HammerLight").progress = round((holdDownCounter - 10) / 30)
			hero.get_node("Hammer").play("Hold")
			hero.get_node("Hammer").rotation_degrees.z = 0
			hero.get_node("Sprite2D").play("HoldHammer1")
			hero.get_node("Hammer").position = Vector3(-0.115, 0.379, -.04)
			if int(round(holdDownCounter / 10)) % 2 == 0:
				hero.get_node("Hammer").position.y += .01
		holdDownCounter += 1.5
	if brokeHold:
		if animationCountdown < 6:
			hero.get_node("Sprite2D").play("HoldHammer2")
			hero.get_node("Hammer").position = Vector3(-.18, .339, -.04)
		elif animationCountdown < 8:
			hero.get_node("Sprite2D").play("HoldHammer1")
			hero.get_node("Hammer").position = Vector3(-.155, .405, -.04)
		elif animationCountdown < 13:
			sfx.play("Swing", false)
			hero.get_node("Hammer").play("SidewaysBlur")
			hero.get_node("Sprite2D").play("Impact1")
			hero.get_node("Hammer").position = Vector3(.183, .268, -.04)
		elif animationCountdown == 13:
			sfx.play("Thud", false)
			hero.unfocus_camera()
			var damage = $"/root/MarioRun".get_equipped_hammer().type.attack
			if hero.get_current_attack().attributes.has("attack"):
				damage += hero.get_current_attack().attributes["attack"]
			hero.get_node("HammerLight").deactivate()
			
			var effectiveness = "GOOD"
			if holdDownCounter > 120:
				effectiveness = "NICE"
				damage += 1
			
			if hero.get_current_attack().attributes.has("hit_all") or target == null:
				get_viewport().get_camera_3d().shake()
				for enemy in hero.get_enemies():
					if not enemy.stats.flying:
						hero.register_damage(enemy, damage, effectiveness)
			else:
				if target.stats.flying:
					hero.register_damage(target, 0, "MISS")
				else:
					hero.register_damage(target, damage, effectiveness)
		elif animationCountdown < 51:
			hero.get_node("Hammer").play("Slam")
			hero.get_node("Sprite2D").play("Impact2")
			hero.get_node("Hammer").position = Vector3(.143, .3, -.04)
		else:
			finish()
			
		animationCountdown += 1

func tween_completed():
	pass
