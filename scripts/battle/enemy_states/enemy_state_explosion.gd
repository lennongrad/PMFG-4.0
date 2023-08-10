extends EnemyState

class_name EnemyExplosionState

var hasCollided = false
var collisionTimer = 0

var readyToDodge = false
var dodged = false
var lastDodgeInput = 0

var explodeTimer = 0
var maxTime = 120

func _ready(): 
	persistent_state.animated_sprite.play("Rest")
#	particles.get_node("BillTrail").emitting = true
#	var adjusted_position = persistent_state.homePosition + Vector3(.3,0,0)
#	interpolate_property(persistent_state, "position", adjusted_position, .8)
#
#	persistent_state.animated_sprite.play("Attack")
#	persistent_state.focus_camera()
	#self.mario.position
#	self.persistent_state.position.z += .1
#	self.persistent_state.velocity.y += 2.5
#	self.persistent_state.velocity.x -= .4
#	self.persistent_state.animated_sprite.play("Rise")
#	self.persistent_state.get_node("Circles").emitting = false

func _physics_process(_delta):
	if(explodeTimer > 75 and not readyToDodge):
		readyToDodge = true
		
	if Input.is_action_pressed("jump") and readyToDodge and not dodged:
		dodged = true
		lastDodgeInput = 0
	lastDodgeInput += 1
	
	explodeTimer += 2
	var flashWhite = explodeTimer % 8 == 0 and explodeTimer > 2 * maxTime / 3
	flashWhite = flashWhite or (explodeTimer % 16 == 0 and explodeTimer > maxTime / 3)
	flashWhite = flashWhite or (explodeTimer % 32 == 0)
	if flashWhite:
		persistent_state.animated_sprite.set_modulate(Color(.2,.2,.2))
	else:
		persistent_state.animated_sprite.set_modulate(Color.WHITE)
	
	
	if explodeTimer > 100:
		if lastDodgeInput < 10:
			persistent_state.register_damage(mario, 2, "NICE", {"no_particles": true, "animation": "BurnDodge"})
			persistent_state.register_damage(partner, 1, "NICE", {"no_particles": true, "animation": "BurnDodge"})
		else:
			persistent_state.register_damage(mario, 3, "MISS", {"no_particles": true, "animation": "BurnHurt"})
			persistent_state.register_damage(partner, 2, "MISS", {"no_particles": true, "animation": "BurnHurt"})
#		particles.get_node("BillTrail").emitting = false
		persistent_state.progress_attack()


func tween_completed():
	pass

func area_body_entered(body):
	pass
