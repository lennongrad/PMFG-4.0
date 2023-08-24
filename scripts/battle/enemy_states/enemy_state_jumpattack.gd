extends EnemyState
 
class_name EnemyJumpattackState

var hasCollided = false
var collisionTimer = 0

var readyToDodge = false
var dodged = false
var lastDodgeInput = 0

func _ready(): 
	self.persistent_state.position.z += .1
	self.persistent_state.velocity.y += 2.5
	self.persistent_state.animated_sprite.play("Rise")
	self.persistent_state.get_node("Circles").emitting = false

func _physics_process(delta):
	var rotationDegrees = rad_to_deg(atan2(persistent_state.velocity.y, persistent_state.velocity.x))
	rotationDegrees -= 90
	animated_sprite.rotation_degrees.z = rotationDegrees
	
	if not hasCollided:
		self.persistent_state.velocity.x = -.4
	
	self.persistent_state.velocity.y -= 4.25 * delta
	if(self.persistent_state.velocity.y < 0):
		self.persistent_state.animated_sprite.play("Fall")
		if not readyToDodge:
			readyToDodge = true
			lastDodgeInput = 0
	if hasCollided and collisionTimer < 10:
		collisionTimer += 1
		self.persistent_state.velocity = Vector3.ZERO
	elif collisionTimer == 10:
		collisionTimer += 1
		if self.persistent_state.get_current_attack().attributes.has("go_past"):
			self.persistent_state.velocity.x = -1
		else:
			self.persistent_state.velocity.y = 1.2
			self.persistent_state.velocity.x = 1
		self.persistent_state.unfocus_camera()
	elif hasCollided:
		if self.persistent_state.lastDodgeSuccessful:
			self.persistent_state.animated_sprite.play("Down")
			self.persistent_state.velocity.y -= 1.75 * delta
			self.persistent_state.animated_sprite.rotate_z(-8 * delta)
		else:
			self.persistent_state.animated_sprite.set_flip_h(true)
			self.persistent_state.velocity.y -= 2 * delta
		
	if Input.is_action_pressed("jump") and readyToDodge and not dodged:
		dodged = true
		lastDodgeInput = 0
	lastDodgeInput += 1
	self.persistent_state.move_and_slide()

func area_body_entered(body):
	if body == persistent_state.current_target.get_node("Area3D") and not hasCollided:
		hasCollided = true
		self.persistent_state.animated_sprite.rotation_degrees.z = 0
		if lastDodgeInput < 10:
			self.persistent_state.register_damage(persistent_state.current_target, 1, "NICE")
		else:
			self.persistent_state.register_damage(persistent_state.current_target, 2, "MISS")
	if body == self.floorMesh:
		self.persistent_state.velocity = Vector3.ZERO
		self.persistent_state.animated_sprite.rotation_degrees.z = 0
		self.persistent_state.get_node("Circles").emitting = self.persistent_state.in_water()
		self.persistent_state.progress_attack()
