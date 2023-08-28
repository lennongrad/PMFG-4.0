extends CharacterBody3D

class_name State

var hero
var target
var sfx

func _physics_process(_delta):
	hero.set_velocity(velocity)
	hero.set_up_direction(Vector3.UP)
	hero.move_and_slide()

func interpolate_property(obj, property, finalValue, time):
	var tween = create_tween()
	tween.tween_property(obj, property, finalValue, time)
	tween.tween_callback(tween_completed)

func setup(p_hero, p_target):
	self.hero = p_hero
	self.target = p_target
	self.velocity = Vector3(0,0,0)
	self.sfx = self.hero.get_node("SFX")

func area_body_entered(_body):
	pass
	
func slingshot_area_body_entered(_body):
	pass

func tween_completed():
	pass
