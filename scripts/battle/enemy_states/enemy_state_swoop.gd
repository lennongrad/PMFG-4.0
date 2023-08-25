extends EnemyState

class_name EnemySwoopState

var hasCollided = false
var collisionTimer = 0

var dodged = false
var lastDodgeInput = 100
var startY

func _ready(): 
	startY = persistent_state.position.y
	self.animated_sprite.get_node("Decoration/Wings").play("FastFlap")
	self.persistent_state.move_and_slide()
	self.persistent_state.velocity = Vector3(-2.75, -2.7, 0)

func _physics_process(delta):
	if persistent_state.position.y > startY:
		self.persistent_state.progress_attack()
	
	if hasCollided:
		self.persistent_state.velocity.x = -.75
	else:
		self.persistent_state.velocity.x = -2.75
	self.persistent_state.velocity.y += .04
	self.persistent_state.velocity.z = 0
	self.persistent_state.move_and_slide()
	
	if Input.is_action_pressed("jump") and not dodged:
		dodged = true
		lastDodgeInput = 0

func area_body_entered(body):
	if body == persistent_state.current_target.get_node("Area3D") and not hasCollided:
		hasCollided = true
		self.persistent_state.animated_sprite.rotation_degrees.z = 0
		if lastDodgeInput < 10:
			self.persistent_state.register_damage(persistent_state.current_target, 1, "NICE")
		else:
			self.persistent_state.register_damage(persistent_state.current_target, 2, "MISS")
		self.animated_sprite.get_node("Decoration/Wings").play("default")
