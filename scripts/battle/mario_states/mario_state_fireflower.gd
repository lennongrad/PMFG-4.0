extends State

class_name FireflowerState

var flowerTimer = 0
var fireFlower
var originalPosition

func _ready():
	hero.get_node("Sprite2D").play("Plant")
	fireFlower = hero.get_node("MoveEffects/FireFlower")
	originalPosition = fireFlower.position.y
	fireFlower.scale = Vector3(.0001, .0001, .0001);

func _process(_delta):
	flowerTimer += 1
	if flowerTimer < 20:
		fireFlower.visible = true
		fireFlower.scale.x += (1 - fireFlower.scale.x) * .15;
	elif flowerTimer < 60:
		hero.unfocus_camera()
		hero.get_node("Sprite2D").play("Rest")
		fireFlower.play("Spout")
	elif flowerTimer < 140:
		fireFlower.play("Spouting")
		hero.get_node("MoveEffects/FireFlower/Particles").emitting = true
	elif flowerTimer < 200:
		fireFlower.play("default")
		fireFlower.scale.x += (-fireFlower.scale.x) * .15;
		hero.get_node("MoveEffects/FireFlower/Particles").emitting = false
		var index = 0
		for enemy in hero.get_enemies():
			if (flowerTimer - 140) == (15 * index):
				hero.register_damage(enemy, 3, "GOOD")
			index += 1
	else:
		fireFlower.visible = false
		hero.get_node("MoveEffects/FireFlower/Particles").emitting = false
		hero.progress_attack()
	
	fireFlower.scale.y = fireFlower.scale.x
	fireFlower.scale.z = fireFlower.scale.x
	fireFlower.position.y = originalPosition - (1 - fireFlower.scale.x) * .3

func tween_completed():
	pass
