extends State

class_name RunState

var smash_light

var first_go = true
var smash_counter = 0
var smash_max = 50
var won = false
var particles_count = 0

func _ready():
	hero.unfocus_camera();
	if hero.in_water():
		hero.get_node("Sprite2D").play("Swim")
	else:
		hero.get_node("Sprite2D").play("Walk")
	hero.get_node("Sprite2D").flip_h = false
	smash_light = hero.get_node("SmashLight")
	smash_light.visible = true
	smash_light.active = true
	smash_light.max_progress = smash_max
	
	self.interpolate_property(hero, "position", hero.get_home_position() + Vector3(.3,0,0), 2.5)

func _process(_delta):
	if first_go:
		particles_count += 1
		if Input.is_action_just_pressed("jump"):
			smash_counter = min(smash_max + 10, smash_counter + 10)
			particles_count = 0
		hero.get_node("RunParticles").emitting = (not hero.in_water()) and particles_count < 2
		smash_counter = max(0, smash_counter - 1)
		smash_light.progress = smash_counter
		smash_light.is_good = smash_counter > smash_max

func tween_completed():
	if first_go:
		first_go = false
		smash_light.active = false
		won = smash_counter > smash_max
		
		if won:
			self.interpolate_property(hero, "position", 
			hero.get_home_position() - Vector3(2,0,0), .75)
			hero.get_node("RunParticles").emitting = false
			hero.get_node("RunSuccessParticles").emitting = not hero.in_water()
		else:
			hero.get_node("RunParticles").emitting = false
			self.hero.progress_attack()
	else:
		hero.end_battle()
