extends EnemyState

class_name EnemyInkState

var squirt_timer = 0

var dodged = false
var lastDodgeInput = 100

func _ready(): 
	persistent_state.focus_camera()

func _physics_process(delta):
	squirt_timer += 1
	if squirt_timer < 20:
		self.animated_sprite.rotation_degrees.z = -squirt_timer * 90 / 20
	elif squirt_timer < 60:
		self.animated_sprite.play("Squirt")
	elif squirt_timer < 80:
		persistent_state.unfocus_camera()
		particles.get_node("Ink").emitting = true
		sfx.play("Squirt", false)
	elif squirt_timer < 130:
		sfx.stop("Squirt")
		self.animated_sprite.rotation_degrees.z = (-90 + (squirt_timer - 80) * 90 / 50)
		particles.get_node("Ink").emitting = false
	else:
		self.persistent_state.progress_attack()
	
	if Input.is_action_pressed("jump") and not dodged:
		dodged = true
		lastDodgeInput = 0
	
	if squirt_timer == 90:
		if lastDodgeInput < 20:
			self.persistent_state.register_damage(persistent_state.current_target, 1, "NICE")
		else:
			self.persistent_state.register_damage(persistent_state.current_target, 2, "MISS")
	
#	if persistent_state.position.y > startY and hasCollided:
#		self.persistent_state.progress_attack()
#
#	if hasCollided:
#		self.persistent_state.velocity.x = -.75
#	else:
#		self.persistent_state.velocity.x = -2.75
#	self.persistent_state.velocity.y += .04
#	self.persistent_state.velocity.z = 0
#	self.persistent_state.move_and_slide()
#

#func area_body_entered(body):
#	if body == persistent_state.current_target.get_node("Area3D") and not hasCollided:
#		hasCollided = true
#		self.persistent_state.animated_sprite.rotation_degrees.z = 0
#		if lastDodgeInput < 10:
#			self.persistent_state.register_damage(persistent_state.current_target, 1, "NICE")
#		else:
#			self.persistent_state.register_damage(persistent_state.current_target, 2, "MISS")
#		self.animated_sprite.get_node("Decoration/Wings").play("default")
