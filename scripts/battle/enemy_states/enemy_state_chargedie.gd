extends EnemyState

class_name EnemyChargedieState

var hasCollided = false
var collisionTimer = 0

var readyToDodge = false
var dodged = false
var lastDodgeInput = 0

var current_tween = 0

func _ready(): 
	var adjusted_position = persistent_state.homePosition + Vector3(.3,0,0)
	interpolate_property(persistent_state, "position", adjusted_position, .8)
	
	persistent_state.animated_sprite.play("Attack")
	persistent_state.focus_camera()
	#self.mario.position
#	self.persistent_state.position.z += .1
#	self.persistent_state.velocity.y += 2.5
#	self.persistent_state.velocity.x -= .4
#	self.persistent_state.animated_sprite.play("Rise")
#	self.persistent_state.get_node("Circles").emitting = false

func _physics_process(_delta):
	if((persistent_state.position - mario.position).length() < .5 and not readyToDodge):
		readyToDodge = true
		
	if Input.is_action_pressed("jump") and readyToDodge and not dodged:
		dodged = true
		lastDodgeInput = 0
	lastDodgeInput += 1
#	self.persistent_state.move_and_slide()

func tween_completed():
	if current_tween == 0:
		current_tween = 1
		var adjusted_position = mario.position
		particles.get_node("BillTrail").emitting = true
		sfx.play("Shoot", false)
		interpolate_property(persistent_state, "position", adjusted_position, .4)

func area_body_entered(body):
	if body == mario.get_node("Area3D") and not hasCollided:
		hasCollided = true
		if lastDodgeInput < 10:
			persistent_state.register_damage(mario, 1, "NICE", {"no_particles": true, "animation": "BurnDodge"})
		else:
			persistent_state.register_damage(mario, 2, "MISS", {"no_particles": true, "animation": "BurnHurt"})
		particles.get_node("BillTrail").emitting = false
		persistent_state.progress_attack()
