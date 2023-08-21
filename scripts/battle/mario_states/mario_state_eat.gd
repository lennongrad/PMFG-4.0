extends State

class_name EatState

var eatTimer = 0

func _ready():
	hero.get_node("EatenItem").position = Vector3(0, .73, 0)
	hero.get_node("EatenItem").scale = Vector3(1,1,1)
	hero.get_node("EatenItem").texture = hero.get_current_attack().icon_texture
	hero.get_node("EatenItem/Particles").emitting = true
	hero.get_node("EatenItem/Particles2").emitting = true

func _process(_delta):
	eatTimer += 1
	if eatTimer < 75:
		hero.get_node("Sprite2D").play("Present")
		hero.get_node("EatenItem").modulate.a += (1 - hero.get_node("EatenItem").modulate.a) * .1
		if eatTimer > 60:
			hero.get_node("EatenItem/Particles").emitting = false
			hero.get_node("EatenItem/Particles2").emitting = false
	elif eatTimer < 150:
		hero.get_node("EatenItem").position = Vector3(0.06, 0.28, .006)
		hero.get_node("EatenItem").scale = Vector3(.75, .75, .75)
		hero.get_node("Sprite2D").play("Eat")
	elif eatTimer == 150:
		if hero.get_current_attack().attributes.has("hp"):
			hero.heal(hero.get_current_attack().attributes["hp"])
		if hero.get_current_attack().attributes.has("fp"):
			hero.gain_fp(hero.get_current_attack().attributes["fp"])
	elif eatTimer < 245:
		hero.get_node("Sprite2D").play("Swallow")
		hero.get_node("EatenItem").modulate.a -= hero.get_node("EatenItem").modulate.a * .1
	else:
		hero.progress_attack()

func tween_completed():
	pass
