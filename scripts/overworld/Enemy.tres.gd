@tool

extends CharacterBody3D

@export var encounter_data: Resource 
@export var battle_background: Resource

# constants
var gravity = 15
var jump_power = 5
@onready var original_translation = global_transform.origin 

enum ENEMY_STATE {CHASE_PLAYER, RETURN_TO_ORIGIN, RANDOM_WALK, DEATH, HURT}

var water_level = 0
var paused = false
var player
var deathTimer = 0
var enemy_bounds: Area3D
var time_since_random = 100
var target = Vector3.ZERO
var spriteRotation = 0
var lastTarget = Vector3.ZERO
var player_in_bounds = false
var state
var chase_y = 0
var blink_timer = 0
var exclamation_timer = 0

# for flying swooping
var flying_target_first = Vector3.ZERO
var flying_target_second = Vector3.ZERO
var past_first = false

signal encounter_triggered(encounteredEnemy, first_strike)

# Called when the node enters the scene tree for the first time.
func _ready():
	state = ENEMY_STATE.RANDOM_WALK

func set_encounter(p_encounter_data):
	encounter_data = p_encounter_data
	$Sprite2D.set_frames(encounter_data.enemies[0].frames)
	if encounter_data.attributes.has("balloons"):
		$Balloons.visible = true
	else:
		$Balloons.visible = false
	if encounter_data.swimming:
		$Circles.emitting = true
	else:
		$Circles.emitting = false
	if encounter_data.flying:
		original_translation += Vector3(0, encounter_data.fly_level, 0)

func _physics_process(delta):
	if paused or Engine.is_editor_hint():
		return
	var shouldSnap = true
	if is_on_wall() and is_on_floor():
		#velocity.y += jump_power
		shouldSnap = false

	var goalDirection
	if target != null:
		goalDirection = Vector2(target.x, target.z) - Vector2(global_transform.origin.x, global_transform.origin.z)
	else:
		goalDirection = Vector2(0,0)
	
	var speed = 0
	match state:
		ENEMY_STATE.RETURN_TO_ORIGIN:
			if goalDirection.length() < .5:
				state = ENEMY_STATE.RANDOM_WALK
				speed = 0
			else:
				speed = 1
		ENEMY_STATE.CHASE_PLAYER:
			speed = 1.5
			if encounter_data.flying:
				speed = 1.5
			if exclamation_timer > 0:
				speed = 0
		ENEMY_STATE.RANDOM_WALK:
			speed = 1
			if goalDirection.length() < .1:
				speed = 0
	if encounter_data.swimming:
		velocity.y = 0
		position.y = (water_level - .2 - original_translation.y)
	if encounter_data.flying:
		velocity.y = ((target.y) - global_position.y) * 2
	
	goalDirection = goalDirection.normalized() * speed
	if true:#not encounter_data.flying or abs(original_translation.y - global_transform.origin.y) < .1:
		velocity = Vector3(goalDirection.x, velocity.y, goalDirection.y)

	if speed > 0:
		goalDirection = goalDirection.rotated(deg_to_rad(rotation_degrees.y))
		$Sprite2D.play("Walk")
		if velocity.x > -0.01:
			if spriteRotation < 180:
				spriteRotation = min(180, spriteRotation + delta * 2000)
		elif velocity.x < 0.01:
			if spriteRotation > 0:
				spriteRotation = max(0, spriteRotation - delta * 2000)
	else:
		$Sprite2D.play("Rest")
		velocity = Vector3.ZERO
	
#	if not encounter_data.flying:
	velocity.y -= gravity * delta * .1
	if shouldSnap:
		set_velocity(velocity)
		# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `Vector3(0,-.1,0)`
		set_up_direction(Vector3(0,1,0))
		set_floor_stop_on_slope_enabled(false)
		set_max_slides(4)
		set_floor_max_angle(PI/4)
		move_and_slide()
		velocity = velocity
	else:
		set_velocity(velocity)
		set_up_direction(Vector3(0,1,0))
		set_floor_stop_on_slope_enabled(false)
		set_max_slides(4)
		set_floor_max_angle(PI/4)
		move_and_slide()
		velocity = velocity
	$Sprite2D.rotation_degrees.y = -spriteRotation

func _process(_delta):
	if paused or Engine.is_editor_hint():
		return
	
#	if (Vector2(global_transform.origin.x, global_transform.origin.z) - 
#		Vector2(original_translation.x, original_translation.z)).length() > 2:
#			state = ENEMY_STATE.RETURN_TO_ORIGIN
	
	if blink_timer > 0:
		blink_timer -= 1
		$Sprite2D.visible = (blink_timer % 16) > 4
	else:
		$Sprite2D.visible = true
	
	exclamation_timer -= 1
	$Exclamation.visible = exclamation_timer > 0
	
	lastTarget = target
	match state:
		ENEMY_STATE.RETURN_TO_ORIGIN:
			target = original_translation
			if not encounter_data.flying:
				target.y = 0
		ENEMY_STATE.CHASE_PLAYER:
			if encounter_data.flying:
				if((global_position - flying_target_second).length() < .2):
					state = ENEMY_STATE.RANDOM_WALK
					time_since_random = 100
				if((global_position - flying_target_first).length() < .2 or past_first):
					past_first = true
					target = flying_target_second
				else:
					target = flying_target_first
#				if (global_position - flying_target_second).length() < .5:
#					state = ENEMY_STATE.RANDOM_WALK
#				elif (global_position - flying_target_first).length() < .5:
#					target = flying_target_second
#				else:
#					target = flying_target_first
			else:
				target = player.position
		ENEMY_STATE.RANDOM_WALK:
			time_since_random += 1
			if time_since_random > 100:
				target = original_translation
				target += (Vector3(50, 0, 50) - Vector3(float(randi() % 100), 0, float(randi() % 100))) * .02
				time_since_random = 0
		ENEMY_STATE.HURT:
			$Sprite2D.play("Hurt")
			$Sprite2D.rotation_degrees.y = 0
		ENEMY_STATE.DEATH:
			$Sprite2D.play("Hurt")
			deathTimer += 2
			if deathTimer < 100:
				$Sprite2D.rotation_degrees.y = -deathTimer * 4.5
			elif deathTimer < 190:
				$Sprite2D.rotation_degrees.y = 0
				$Sprite2D.fallTimer = deathTimer - 80
			else:
				queue_free()

func return_to_bounds():
	if state == ENEMY_STATE.DEATH:
		return
	state = ENEMY_STATE.RETURN_TO_ORIGIN

func chase_player():
	if state == ENEMY_STATE.DEATH or state == ENEMY_STATE.RETURN_TO_ORIGIN:
		return
	state = ENEMY_STATE.CHASE_PLAYER
	exclamation_timer = 20
	
	# for flying swooping
	flying_target_first = player.position
	flying_target_second = (player.position - position) * 2
	flying_target_second.y = original_translation.y
	past_first = false

func play_hurt():
	$HurtParticles.play()
	state = ENEMY_STATE.HURT;
	$Sprite2D.play("Hurt")

func xz(vector):
	return Vector2(vector.x, vector.z)

func xyz(vector):
	return Vector3(vector.x, 0, vector.y)

func die():
	state = ENEMY_STATE.DEATH
	$CollisionShape3D.disabled = true
	$Balloons.pop()
	position += (xyz(xz(global_transform.origin) - xz(player.global_transform.origin)) * (1.5 + float(randi() % 4) / 4)
		+ Vector3(1 - float(randi() % 4) / 2, 0, 1 - float(randi() % 4) / 2) * .15)
	for _i in range(0, 5 + randi() % 5):
		var coin = load("res://scenes/overworld/OverworldCoin.tscn").instantiate()
		$"../..".add_child(coin)
		var difference =  Vector3(1 - float(randi() % 8) / 4, 0, 1 - float(randi() % 8) / 4) 
		coin.position = global_transform.origin + difference * Vector3(.1, 1, .1)
		coin.timer = coin.timer * 1.5 - 15

func run_away():
	blink_timer = 300
	state = ENEMY_STATE.RETURN_TO_ORIGIN

func player_entered():
	player_in_bounds = true

func player_exited():
	player_in_bounds = false

func _on_pause():
	paused = true

func _on_unpause():
	paused = false

func _on_NormalEncounter_area_entered(area):
	if paused or player == null or state == ENEMY_STATE.DEATH or blink_timer > 0:
		return
	match area:
		player.normal_area:
			var difference = velocity.normalized() - player.velocity.normalized()
			difference.y = 0
			if difference.length() > .5:
				emit_signal("encounter_triggered", self, "")
			else:
				emit_signal("encounter_triggered", self, "enemy")
		player.hammer_area:
			emit_signal("encounter_triggered", self, "hammer")
		player.jump_area:
			emit_signal("encounter_triggered", self, "jump")

func _on_Detection_body_entered(body):
	if body == player and state == ENEMY_STATE.RANDOM_WALK:
		chase_player()

func _on_Detection_body_exited(body):
	if body == player:# and player_in_bounds:
		pass#return_to_bounds()
