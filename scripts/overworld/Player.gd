extends CharacterBody3D

# constants
const speed = 2.5
const gravity = 20
const jump_power = 5.5

var last_significant_velocity = Vector3.ZERO
var last_direction = Vector3.ZERO
var spriteRotation = 0
var current_speed = 0
var paused = false
var dont_snap_next_frame = false
var is_in_water = false
var is_diag = false
var is_wall_sliding = true
var not_sliding_timer = 0
var hammer_type
var pipe_position = Vector3(0,0,0)
var pipe_position_exit = Vector3(0,0,0)
var over_pipe = false
var original_sprite_y = .376
var jump_timer = 0

# manage falling off collision
var last_ground_position = []
var down_timer = 0

enum PLAYER_STATE {CONTROL, SPINNING, HAMMER, PIPE, EXIT, ITEM, MENU, DOWN}
var state = PLAYER_STATE.CONTROL

var spin_timer = 0
var hammer_timer = 0
var item_timer = 0
var over_pipe_timer = 0
var exiting_timer = 0
var pipe_fall_timer = 0

@onready var original_translation_y = $CameraFar.position.y
var last_height = 0
var rest_timer = 0
var after_growing = false

@onready var normal_area = $NormalArea
@onready var hammer_area = $HammerArea
@onready var jump_area = $JumpArea

# Called when the node enters the scene tree for the first time.
func _ready():
	update_hammer(get_node("/root/MarioRun").get_equipped_hammer().type)
	original_sprite_y = $AnimatedSprite3D.position.y
	last_ground_position.append(position)

func do_wall_slide():
	if !is_on_wall():
		return false
	if jump_timer <= 0:
		return false
	if position.y < -2:
		return false
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal_cross = collision.get_normal().cross(Vector3.LEFT)
		if(abs(normal_cross.y) <= .1):
			return true
	return false

func _physics_process(delta):
	if paused:
		if state == PLAYER_STATE.HAMMER:
			if is_diag:
				$Hammer.play("DiagBlur")
				$AnimatedSprite3D.play("DiagImpact")
			else:
				$Hammer.play("SidewaysBlur")
				$AnimatedSprite3D.play("Impact1")
		if state == PLAYER_STATE.MENU:
			$"../Status".unhide()
		return
	var shouldSnap = true
	
	if Input.is_action_just_pressed("ui_down"):
		if over_pipe_timer > 15 and over_pipe:
			state = PLAYER_STATE.EXIT
			$"..".start_exit()
			position.x = pipe_position_exit.x
			position.z = pipe_position_exit.z
	
	if position.y < -10:
		position = last_ground_position.front()
		state = PLAYER_STATE.DOWN
		down_timer = 0
		velocity = Vector3.ZERO
		return
	
	$WallJumpParticles.emitting = false
	$SpinDashParticles.emitting = false
	match state:
		PLAYER_STATE.SPINNING:
			$SpinDashParticles.emitting = true
		PLAYER_STATE.PIPE:
			$"../Status".hide()
			if not after_growing:
				$AnimatedSprite3D.play("Down")
		PLAYER_STATE.EXIT:
			over_pipe_timer = 0
			exiting_timer += 1
			spriteRotation += min(30, exiting_timer * .3)
			position.y -= .005
			if exiting_timer == 50:
				$"..".finish_exit()
			$AnimatedSprite3D.play("LookDown")

	if is_on_floor():
		jump_timer = 0
		
		var space = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_position, global_position - Vector3(0,1,0))
		var collision = space.intersect_ray(query)
		if collision:
			if ((position - last_ground_position.back()).length() > .2):
				last_ground_position.append(position)
				if last_ground_position.size() > 5:
					last_ground_position.pop_front()
		
		
		is_wall_sliding = false
		last_height = position.y
		over_pipe_timer += 1
		
		if after_growing and state == PLAYER_STATE.PIPE:
			$"..".finished_pipe()
			pipe_fall_timer += 1
		
		if pipe_fall_timer > 0 and pipe_fall_timer < 10:
			$FallParticles.emitting = true
		else:
			$FallParticles.emitting = false
		
		if pipe_fall_timer > 20 and state == PLAYER_STATE.PIPE:
			$AnimatedSprite3D.play("GetUp")
		
		var effective_jump_power = jump_power
		if is_in_water:
			effective_jump_power *= .5
		velocity = Vector3(0, velocity.y, 0)
		
		if Input.is_action_just_pressed("jump") and (state == PLAYER_STATE.CONTROL or state == PLAYER_STATE.SPINNING):
			jump_timer = -6
			velocity.y += effective_jump_power
			shouldSnap = false
		
		if state == PLAYER_STATE.CONTROL:
			if Input.is_action_pressed("ui_right"):
				velocity.x = 1
			elif Input.is_action_pressed("ui_left"):
				velocity.x = -1
			else:
				velocity.x = 0
			if Input.is_action_pressed("ui_down"):
				velocity.z = 1
			elif Input.is_action_pressed("ui_up"):
				velocity.z = -1
			else:
				velocity.z = 0
			if Input.is_action_just_pressed("spin") and spin_timer >= 0 and not is_in_water:
				state = PLAYER_STATE.SPINNING
				last_direction = velocity.normalized()
				spin_timer = 30
			if Input.is_action_just_pressed("back") and not is_in_water:
				state = PLAYER_STATE.HAMMER
				hammer_timer = 0
				hammer_stuck = false
				if spriteRotation == 180 or spriteRotation == 0:
					pass
				if Input.is_action_pressed("ui_right"):
					spriteRotation = 180
				elif Input.is_action_pressed("ui_left"):
					spriteRotation = 0
			
		if is_on_wall():
			position.y += .08
		
		if Vector2(velocity.x, velocity.z) != Vector2.ZERO:
			current_speed += (speed - current_speed) * delta * 5
		else:
			current_speed = 0
		
		var horizontalVelocity = Vector2(velocity.x, velocity.z)
		horizontalVelocity = horizontalVelocity.rotated(deg_to_rad(-rotation_degrees.y))
		
		$Hammer.visible = false
		$ItemGet.visible = false
		
		match state:
			PLAYER_STATE.SPINNING:
				spriteRotation += (45 - abs(spin_timer - 15) * 3) * 60 * delta
				
				spin_timer -= 1
				if spin_timer == 0:
					state = PLAYER_STATE.CONTROL
					spriteRotation = 0
					spin_timer = -30
				
				var effective_speed = speed
				if is_in_water:
					effective_speed *= .5
				horizontalVelocity = last_direction * effective_speed * 2
				horizontalVelocity = Vector2(horizontalVelocity.x, horizontalVelocity.z)
				velocity.x = horizontalVelocity.x
				velocity.z = horizontalVelocity.y
				$AnimatedSprite3D.play("Spinning")
				$SpinDashParticles.emitting = true
			PLAYER_STATE.ITEM:
				spriteRotation = 0
				$ItemGet.visible = true
				item_timer += 1
				if item_timer < 20:
					$AnimatedSprite3D.play("Pickup")
				else:
					if item_timer > 60:
						$ItemGet.disable()
					if Input.is_action_just_pressed("jump"):
						$Checkers.visible = false
						$Checkers2.visible = false
						#$"../Camera3D".cull_mask = 1047551
						state = PLAYER_STATE.CONTROL
						shouldSnap = true
				$"../Status".unhide()
			PLAYER_STATE.CONTROL:
				if spin_timer < 0:
					spin_timer += 1
				if horizontalVelocity.length() > 0.01:
					var effective_speed = current_speed
					if is_in_water:
						effective_speed *= .5
					horizontalVelocity = horizontalVelocity.normalized() * effective_speed
					velocity.x = horizontalVelocity.x
					velocity.z = horizontalVelocity.y
					
					horizontalVelocity = horizontalVelocity.rotated(deg_to_rad(rotation_degrees.y))
					if horizontalVelocity.y < -.01:
						is_diag = true
					elif horizontalVelocity.y > .01 or abs(horizontalVelocity.x) > .05:
						is_diag = false
					
					rest_timer = 0
					over_pipe_timer = 0
					
					if is_in_water:
						$AnimatedSprite3D.play("Swim")
					else:
						if is_diag:
							$AnimatedSprite3D.play("DiagWalk")
						else:
							$AnimatedSprite3D.play("HorizontalWalk")
					
					if horizontalVelocity.x > 0.05:
						if spriteRotation < 180:
							spriteRotation = min(180, spriteRotation + delta * 2000)
					elif horizontalVelocity.x < -0.05:
						if spriteRotation > 0:
							spriteRotation = max(0, spriteRotation - delta * 2000)
				else:
					if is_in_water:
						$AnimatedSprite3D.play("Swim")
					else:
						if is_diag:
							$AnimatedSprite3D.play("DiagRest")
						else:
							$AnimatedSprite3D.play("Rest")
					if spriteRotation > 90:
						spriteRotation = 180
					else:
						spriteRotation = 0
					rest_timer += 1
				
				if rest_timer > 60 && $"../Status" != null:
					$"../Status".unhide()
				
				if Input.is_action_just_pressed("menu"):
					state = PLAYER_STATE.MENU
					$"..".open_menu()
			PLAYER_STATE.DOWN:
				down_timer += 1
				$AnimatedSprite3D.play("Down")
				$FallParticles.emitting = down_timer < 20
				if down_timer > 50:
					state = PLAYER_STATE.CONTROL
			PLAYER_STATE.HAMMER:
				$Hammer.visible = true
				hammer_timer += 1
				if hammer_timer < 2:
					$Hammer.rotation_degrees.z = 0
					if is_diag:
						$AnimatedSprite3D.play("DiagPreparation")
						$Hammer.play("DiagHold")
						$Hammer.position = Vector3(-.103, .46, .049)
					else:
						$AnimatedSprite3D.play("HoldHammer1")
						$Hammer.play("Hold")
						$Hammer.position = Vector3(-0.115, 0.478, -.04)
				elif hammer_timer < 3:
					$Hammer.rotation_degrees.z = 0
					if is_diag:
						$AnimatedSprite3D.play("DiagPreparation")
						$Hammer.position = Vector3(-.103, .46, .049)
					else:
						$AnimatedSprite3D.play("HoldHammer2")
						$Hammer.position = Vector3(-.161, .387, -.04)
				elif hammer_timer < 5:
					if is_diag:
						$AnimatedSprite3D.play("DiagPreparation")
						$Hammer.position = Vector3(-.103, .46, .049)
					else:
						$AnimatedSprite3D.play("HoldHammer1")
						$Hammer.position = Vector3(-0.115, 0.478, -.04)
				elif hammer_timer < 6:
					if is_diag:
						$Hammer.play("DiagBlur")
						$AnimatedSprite3D.play("DiagImpact")
					else:
						$Hammer.play("SidewaysBlur")
						$AnimatedSprite3D.play("Impact1")
					$Hammer.position = Vector3(.183, .268, -.04)
				elif hammer_timer == 6:
					if spriteRotation == 0:
						if is_diag:
							$HammerArea.rotation_degrees.y = -30
						else:
							$HammerArea.rotation_degrees.y = 0
					else:
						if is_diag:
							$HammerArea.rotation_degrees.y = -150
						else:
							$HammerArea.rotation_degrees.y = -180
					$HammerArea/CollisionShape3D.disabled = false
					$Hammer.position = Vector3(.183, .268, -.04)
					$HammerArea.play()
					$CameraClose.shake()
					$CameraFar.shake()
				elif hammer_timer < 30:
					if hammer_timer > 12:
						$HammerArea/CollisionShape3D.disabled = true
					if not hammer_stuck:
						if is_diag:
							$Hammer.play("Diag")
						else:
							$Hammer.play("Slam")
							$AnimatedSprite3D.play("Impact2")
						$Hammer.position = Vector3(.143, .3, -.04)
					else:
						$Hammer.rotation_degrees.z = 90
						if is_diag:
							$Hammer.play("DiagHold")
							$AnimatedSprite3D.play("DiagStuck")
						else:
							$Hammer.play("Hold")
							$AnimatedSprite3D.play("Stuck")
						$Hammer.position = Vector3(.117, .232, -.04)
				else:
					state = PLAYER_STATE.CONTROL
				if spriteRotation == 0:
					$Hammer.flip_h = false
					$Hammer.position.x *= -1
				else:
					$Hammer.flip_h = true
					if $Hammer.rotation_degrees.z > 0:
						$Hammer.rotation_degrees.z *= -1
	else:
		jump_timer += 1
		match state:
			PLAYER_STATE.SPINNING:
				state = PLAYER_STATE.CONTROL
				current_speed = speed * .5
			PLAYER_STATE.CONTROL:
				var horizontalVelocity = Vector2(velocity.x, velocity.z)
				horizontalVelocity = horizontalVelocity.rotated(deg_to_rad(rotation_degrees.y))
				
				if last_height > position.y:
					last_height = position.y
				if position.y > last_height + 1:
					last_height += .1
				
				var airSpeed = speed
				if is_wall_sliding:
					airSpeed *= .1
				if Input.is_action_pressed("ui_right"):
					horizontalVelocity.x = max(-airSpeed, horizontalVelocity.x + airSpeed * delta * 2)
				elif Input.is_action_pressed("ui_left"):
					horizontalVelocity.x = min(airSpeed, horizontalVelocity.x - airSpeed * delta * 2)
				if Input.is_action_pressed("ui_down"):
					horizontalVelocity.y = max(-airSpeed, horizontalVelocity.y + airSpeed * delta * 2)
				elif Input.is_action_pressed("ui_up"):
					horizontalVelocity.y = min(airSpeed, horizontalVelocity.y - airSpeed * delta * 2)
				
				
				if horizontalVelocity.length() > airSpeed:
					horizontalVelocity = horizontalVelocity.normalized() * airSpeed
				
				if velocity.y < -0.1:
					if is_diag:
						$AnimatedSprite3D.play("DiagFall")
					else:
						$AnimatedSprite3D.play("HorizontalFall")
				elif velocity.y > 0.1:
					if is_diag:
						$AnimatedSprite3D.play("DiagRise")
					else:
						$AnimatedSprite3D.play("HorizontalRise")
				if is_wall_sliding:
					$AnimatedSprite3D.play("Walljump")
				horizontalVelocity = horizontalVelocity.rotated(deg_to_rad(-rotation_degrees.y))
				velocity = Vector3(horizontalVelocity.x, velocity.y, horizontalVelocity.y)
				
				if do_wall_slide():
					if velocity.y < 0:
						velocity.y = -.6
					if velocity.y > 0:
						velocity.y -= .1
					is_wall_sliding = true
					not_sliding_timer = 0
					spriteRotation = 180
					var normal = get_slide_collision(0).get_normal()
					if abs(normal.z) < .01:
						normal.z = 0
					if abs(normal.x) < .01:
						normal.x = 0
					normal.y = 0
					$WallJumpParticles.emitting = true
					if normal.x > 0.1:
						spriteRotation = 180
						$WallJumpParticles.position.x = -0.158
					elif normal.x < -.1:
						spriteRotation = 0
						$WallJumpParticles.position.x = 0.158
					if Input.is_action_just_pressed("jump"):
						velocity = Vector3(0, 5.5, 0) + normal * 10
						is_wall_sliding = false
				else:
					is_wall_sliding = false
					if horizontalVelocity.x > 0:
						spriteRotation = 180
					else:
						spriteRotation = 0
	if dont_snap_next_frame:
		dont_snap_next_frame = false
		shouldSnap = false
	if current_speed > speed * .8:
		last_significant_velocity = velocity
	
	var effective_gravity = gravity
	if is_in_water:
		effective_gravity *= .2
	
	if over_pipe_timer > 15 and over_pipe:
		$StickDown.modulate.a += (1 - $StickDown.modulate.a) * .05
	else:
		$StickDown.modulate.a -= $StickDown.modulate.a * .2
	
	velocity.y -= effective_gravity * delta
	if state != PLAYER_STATE.EXIT:
		if shouldSnap:
			set_velocity(velocity)
			# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `Vector3(0,-.1,0)`
			set_up_direction(Vector3(0,1,0))
			set_floor_stop_on_slope_enabled(false)
			set_max_slides(4)
			set_floor_max_angle(PI/4)
			# TODOConverter40 infinite_inertia were removed in Godot 4.0 - previous value `false`
			move_and_slide()
			velocity = velocity
			if is_on_wall() and is_wall_sliding:
				velocity -= get_slide_collision(0).get_normal() * .001
		else:
			set_velocity(velocity)
			set_up_direction(Vector3(0,1,0))
			set_floor_stop_on_slope_enabled(false)
			set_max_slides(4)
			set_floor_max_angle(PI/4)
			# TODOConverter40 infinite_inertia were removed in Godot 4.0 - previous value `false`
			move_and_slide()
			velocity = velocity
	
	$AnimatedSprite3D.rotation_degrees.y = -spriteRotation
	$CameraFar.position.y = original_translation_y - position.y + last_height

func start_pipe():
	state = PLAYER_STATE.PIPE
	visible = false

func _on_finished_growing():
	after_growing = true
	velocity.y = 6
	velocity.x = 14
	visible = true

func finished_shrinking():
	state = PLAYER_STATE.CONTROL

func update_hammer(type):
	hammer_type = type
	$Hammer.frames = hammer_type.frames

func collect_item(item):
	state = PLAYER_STATE.ITEM
	$ItemGet.set_item(item)
	item_timer = 0
	$Checkers.visible = true
	$Checkers2.visible = true
	#$"../Camera3D".cull_mask = 1048574

func bounce():
	dont_snap_next_frame = true
	velocity = Vector3(0, 4, 0)

func get_camera_3d():
	match state:
		PLAYER_STATE.ITEM: return $CameraClose;
	return $CameraFar

func play_jump():
	$AnimatedSprite3D.play("HorizontalRise")

func play_hurt():
	$AnimatedSprite3D.rotation_degrees.y = 0
	$AnimatedSprite3D.play("Hurt")
	$HurtParticles.play()

func enter_water(y_position):
	is_in_water = true
	$WaterParticles.set_global_position(Vector3(
		$WaterParticles.global_position.x, 
		y_position - .2, 
		$WaterParticles.global_position.z));
	$WaterParticles.play()

func exit_water(y_position):
	is_in_water = false
	$WaterParticles.set_global_position(Vector3(
		$WaterParticles.global_position.x, 
		y_position - .2, 
		$WaterParticles.global_position.z));
	$WaterParticles.play()

func collected_coin():
	get_node("/root/MarioRun").change_coins(1)
	$"../Status".unhide()
	$CoinParticles.play()

func end_menu():
	state = PLAYER_STATE.CONTROL

func _on_pause():
	paused = true

func _on_unpause():
	paused = false

func _on_pipe_detect_entry(body):
	if body == self:
		over_pipe = true
		over_pipe_timer = 0

func on_pipe_detect_exit(body):
	if body == self:
		over_pipe = false
		over_pipe_timer = 0

var hammer_stuck
func _on_HammerArea_body_entered(_body):
	hammer_stuck = true
