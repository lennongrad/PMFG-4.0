extends CharacterBody3D

var rng = RandomNumberGenerator.new()

@export var stats: Resource
@export var is_partner: bool

@onready var stage = $"../Floor"
var front_position = Vector3(0, 0, 0)
var back_position = Vector3(-.7, 0, -.2)
var battle_tag
var state_factory

var state 
var attack_animation_counter = 0
var current_chosen_attack
var target
var is_victory_posing = false
var is_selected_teammate = false
var guarding = false
var is_idle = false
var first_strike_active = false
var is_in_water = false
var level_up_waiting = false
var animation_wait = 0

func _ready():
	$Sprite2D.frames = stats.frames_texture
	$Sprite2D.particle_mesh = stats.jump_particles
	$Sprite2D.play("Rest")
	
	$Hammer.visible = false
	
	state_factory = HeroStateFactory.new()
	change_state("idle")
	
	$Hammer.frames = get_node("/root/MarioRun").get_equipped_hammer().type.frames

func get_enemies():
	return $"..".enemies

func get_choices():
	return  $"/root/MarioRun".get_choices(stats)

func get_home_position():
	if is_selected_teammate:
		return front_position
	else:
		return back_position

func change_state(new_state_name):
	if(state != null):
		state.queue_free()
	state = state_factory.get_state(new_state_name).new()
	state.setup(self, target)
	state.name = "current_state"
	add_child(state)

func in_water():
	return is_in_water

func get_current_attack():
	return current_chosen_attack

func get_hp():
	return  $"/root/MarioRun".get_hp(stats)

func register_damage(targets, damage, effectiveness):	
	var done_damage = damage + $"/root/MarioRun".get_badge_value("attack")
	
	var damage_dealt = $"..".register_damage(targets, done_damage, effectiveness)
	
	gain_fp($"/root/MarioRun".get_badge_value("fp_drain"))
	heal($"/root/MarioRun".get_badge_value("hp_drain"))
	
	return damage_dealt

func attack(f_attack, enemy):
	current_chosen_attack = f_attack
	target = enemy
	if attack_animation_counter == 0:
		progress_attack()

func end_battle():
	$"..".finish_battle()

func progress_attack():
	if get_current_attack().steps.size() > attack_animation_counter:
		change_state(get_current_attack().steps[attack_animation_counter])
		attack_animation_counter += 1
	else:
		attack_animation_counter = 0
		unfocus_camera()
		change_state("idle")
		$"..".hero_finished(get_current_attack().firstStrike)

func take_damage(damage, effectiveness, attributes = {}):
	var done_damage = damage - $"/root/MarioRun".get_badge_value("defense")
	
	var chance_hit = 1.0
	if $"/root/MarioRun".get_badge_value("lucky") > 0:
		chance_hit *= ($"/root/MarioRun".get_badge_value("lucky",true))
	if $"/root/MarioRun".get_badge_value("danger_lucky") > 0 and done_damage >= get_hp():
		chance_hit *= ($"/root/MarioRun".get_badge_value("danger_lucky",true))
	if rng.randf_range(0.0, 1.0) > chance_hit:
		done_damage = 0
		effectiveness = "LUCKY"
	
	if effectiveness == "NICE":
		$FeedbackParticle.start_nice(-1)
		guard(attributes)
	elif effectiveness == "LUCKY":
		$FeedbackParticle.start_lucky(-1)
		guard(attributes)
	elif effectiveness == "MISS":
		$FeedbackParticle.start_miss(-1)
		hurt(attributes)
	
	var dealt_damage = $"/root/MarioRun".take_damage(stats, done_damage)
	
	if effectiveness != "LUCKY":
		var starDamageDisplay = load("res://scenes/battle/StarDamageDisplay.tscn").instantiate()
		starDamageDisplay.set_name("battle_tag")
		starDamageDisplay.flipped = true
		starDamageDisplay.damage = dealt_damage
		starDamageDisplay.scale = Vector3(-.1,.1,1)
		add_child(starDamageDisplay)
	
	return dealt_damage

func guard(attributes):
	var animation_shown = "Guard"
	if attributes.has("animation"):
		animation_shown = attributes["animation"]
	$Sprite2D.play(animation_shown)
	if not attributes.has("no_particles"):
		$DodgeParticles.play()
	animation_wait = 30

func hurt(attributes):
	var animation_shown = "Hurt"
	if attributes.has("animation"):
		animation_shown = attributes["animation"]
	$Sprite2D.play(animation_shown)
	if not attributes.has("no_particles"):
		$HurtParticles.play()
	animation_wait = 30

func gain_fp(gain_for):
	var gained = $"/root/MarioRun".gain_fp(gain_for)
	if gained > 0:
		$FPUp.change_text("+" + str(gained) + " FP")
		$FPUp.reactivate()
		$Flowers.activate()

func heal(heal_for):
	var healed = $"/root/MarioRun".heal(stats, heal_for)
	if healed > 0:
		$HPUp.change_text("+" + str(healed) + " HP")
		$HPUp.reactivate()
		$Hearts.activate()

func play_victory_pose():
	is_victory_posing = true
	change_state("victory")

func focus_camera(camera):
	var attemptCamera = get_node_or_null("Camera"+str(camera))
	if(attemptCamera != null):
		$"../Camera3D".set_camera_position(attemptCamera)
	else:
		print("Failed to focus on " + str(camera))

func unfocus_camera():
	$"../Camera3D".reset_position()

func get_experience_waiting():
	return $"..".experience_waiting

func check_for_level_ups():
	if not level_up_waiting:
		if $"/root/MarioRun".get_level_ups() > 0:
			level_up_waiting = true
			$"..".start_level_up()
			unfocus_camera()
	return level_up_waiting

func finished_level_up():
	level_up_waiting = false
	heal($"/root/MarioRun".get_max_hp(stats))

func _process(_delta):
	animation_wait -= 1
	$HammerLight.set_position($"../Camera3D".unproject_position(get_position()) - Vector2(75, 200))
	$SmashLight.set_position($"../Camera3D".unproject_position(get_home_position()) - Vector2(125, 200))

func _physics_process(_delta):
	move_and_slide()

func _on_SlingshotArea_body_entered(body):
	state.slingshot_area_body_entered(body)

func _on_Tween_tween_completed(_object, _key):
	state.tween_completed()

func _on_Area_area_entered(area):
	state.area_body_entered(area)
