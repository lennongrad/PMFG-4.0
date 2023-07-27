extends EnemyState

class_name EnemySlingshotState

var hasCollided = false
var collisionTimer = 0

var readyToDodge = true
var dodged = false
var lastDodgeInput = 0

var shootTimer = Timer.new()

func _ready(): 
	self.persistent_state.focus_camera();
	self.persistent_state.animated_sprite.play("Slingshot")
	shootTimer.wait_time = .5
	shootTimer.connect("timeout", Callable(self, "shoot"))
	add_child(shootTimer)
	shootTimer.start()

func shoot():
	self.persistent_state.unfocus_camera();
	self.persistent_state.animated_sprite.play("Rest")
	self.persistent_state.slingshot_ammo.position = self.persistent_state.slingshotHomePosition
	self.persistent_state.slingshot_ammo.visible = true
	print(self.persistent_state.position)
	self.persistent_state.slingshotVelocity = (self.partner.position - self.persistent_state.position) * 2
	shootTimer.call_deferred("free")

func _physics_process(delta):
	if hasCollided and collisionTimer < 10:
		collisionTimer += 1
		self.persistent_state.slingshotVelocity = Vector3.ZERO
	elif collisionTimer == 10:
		collisionTimer += 1
		self.persistent_state.slingshotVelocity.y = 1.2
		self.persistent_state.slingshotVelocity.x = 1
		self.persistent_state.unfocus_camera()
	elif hasCollided:
		if self.persistent_state.lastDodgeSuccessful:
			self.persistent_state.slingshotVelocity.y -= 4 * delta
		else:
			self.persistent_state.slingshotVelocity.y -= 4 * delta
		
	if Input.is_action_pressed("jump") and readyToDodge and not dodged:
		dodged = true
		lastDodgeInput = 0
	lastDodgeInput += 1
	self.persistent_state.slingshot_ammo.velocity = self.persistent_state.slingshotVelocity
	self.persistent_state.slingshot_ammo.move_and_slide()

func slingshot_area_body_entered(body):
	if body == self.partner.get_node("Area3D") and not hasCollided:
		hasCollided = true
		if lastDodgeInput < 10:
			self.persistent_state.register_damage(self.partner, 1, "NICE")
		else:
			self.persistent_state.register_damage(self.partner, 2, "MISS")
	if body == self.floorMesh:
		self.persistent_state.slingshot_ammo.visible = false
		self.persistent_state.slingshotVelocity = Vector3.ZERO
		self.persistent_state.slingshot_ammo.position.y = 10
		self.persistent_state.progress_attack()
