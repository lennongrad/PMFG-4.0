extends State

class_name JumpattackState

var hasCollided = false
var collisionTimer = 0
var pause_timer = 0
var hasFinished = false
var jumpCounter = 0
var jumpMax = 115
var pause_max = 10

var readyToDodge = false
var dodged = false
var lastDodgeInput = 0
var jumpsquat = true
var gravity = 12.0
var enemyTopHeight
var last_successful = false
var hurt_self = false

func _ready(): 
	hero.focus_camera(1);
	hero.get_node("Sprite2D").play("Jumpsquat")
	interpolate_property(hero, "rotation_degrees:x", 
		0, .1)
#	hero.get_node("Tween").start()
	enemyTopHeight = target.position.y + target.stats.height
	hero.position = hero.target.position - Vector3(hero.get_current_attack().walkto_distance, 0, 0)
	hero.position.y = 0
	hero.get_node("Circles").emitting = false
	jumpMax = hero.get_current_attack().attributes["max_jump"]

func _physics_process(delta):	
	if jumpsquat:
		return
	
	self.hero.velocity.y -= gravity * delta
	
	if(self.hero.velocity.y < 0 and not hasCollided):
		self.hero.velocity.y -= gravity * delta
		self.hero.position.x += self.hero.velocity.x * delta / 4
	
	if self.hero.velocity.y < 0 and (jumpCounter == 0 or collisionTimer > 10):
		if not readyToDodge:
			readyToDodge = true
			lastDodgeInput = 0
	else:
		hero.get_node("Sprite2D").play("BattleRise")
	
	if hasCollided and collisionTimer < 10:
		collisionTimer += 1
		self.hero.velocity = Vector3.ZERO
		var targetPos = target.global_transform.origin
		hero.position = targetPos + Vector3(0,  target.stats.height + collisionTimer * .01 - .05, 0)
		hero.get_node("Sprite2D").play("Stomp")
	elif hasCollided and collisionTimer == 10:
		collisionTimer += 1
		if not hasFinished:
			self.hero.velocity.y = 3.75
			hero.get_node("Sprite2D").emitting = true
		else:
			self.hero.velocity.y = 1.75
			self.hero.velocity.x = -1
			if last_successful:
				self.hero.velocity.y *= .75
				self.hero.velocity.x *= 2.5
			hero.get_node("Sprite2D").emitting = false
	
	if hasCollided and pause_timer < pause_max and collisionTimer > 10 and abs(self.hero.velocity.y) < .1:
		pause_timer += 1
		self.hero.velocity.y = gravity * delta
		hero.get_node("Sprite2D").rotation_degrees.y = 360 * (float(pause_timer) / pause_max)
	
	if pause_timer > pause_max:
		pause_timer += 1
		self.hero.velocity.y = -.5
	
	if hasFinished:
		hero.get_node("Sprite2D").flip_h = true
		self.hero.velocity.y -= 2 * delta
		hero.get_node("Sprite2D").rotation_degrees.z = 0
		
		if hurt_self:
			hero.get_node("Sprite2D").play("Hurt")
		else:
			hero.get_node("Sprite2D").play("BattleFall")
		hero.get_node("Sprite2D").rotation_degrees.y = 0
		
	if Input.is_action_pressed("jump") and readyToDodge and not dodged:
		dodged = true
		lastDodgeInput = 0
	lastDodgeInput += 1
	
	if hero.is_partner and not hurt_self:
		hero.get_node("Sprite2D").play("Rise")
		var rotationDegrees = rad_to_deg(atan2(self.hero.velocity.y, self.hero.velocity.x))
		rotationDegrees -= 90
		hero.get_node("Sprite2D").rotation_degrees.z = rotationDegrees
	
	if hero.position.y < 0:
		self.hero.velocity = Vector3.ZERO
		hero.get_node("Sprite2D").rotation_degrees.z = 0
		hero.position.y = 0
		hero.get_node("Circles").emitting = hero.in_water()
		hero.progress_attack()

func area_body_entered(body):
	if body == target.get_node("Area3D") and not hasFinished:
		var actionSuccessful = lastDodgeInput < 8
		last_successful = actionSuccessful
		
		if target.stats.spiky and not $"/root/MarioRun".get_badge_value("spiky_shield") >= 1:
			hero.take_damage(1, "MISS")
			hurt_self = true
			hasFinished = true
		else:
			var damage = $"/root/MarioRun".get_equipped_boots().type.attack
			if hero.get_current_attack().attributes.has("attack"):
				damage += hero.get_current_attack().attributes["attack"]
			if jumpCounter > 4:
				damage = max(damage - jumpCounter + 4, 1)
				
			if actionSuccessful:
				jumpCounter += 1
				if jumpCounter < jumpMax:
					self.hero.velocity.y = 1.6
					self.hero.velocity.x = 0
					readyToDodge = false
					dodged = false
					lastDodgeInput = 0
				else:
					hasFinished = true
				
				if hero.register_damage(target, damage, "NICE"):
					hasFinished = true
			else:
				hasFinished = true
				hero.register_damage(target, damage, "GOOD")
		
		collisionTimer = 0
		pause_timer = 0
		hasCollided = true

func tween_completed():
	var distance = target.position.x - self.hero.position.x
	var horizontal_velocity = distance * 1.4
	self.hero.velocity.x = horizontal_velocity
	self.hero.velocity.y = (gravity / 2) * distance / horizontal_velocity + enemyTopHeight / distance * horizontal_velocity;
	jumpsquat = false
	if hero.in_water():
		hero.get_node("WaterParticles").play()
