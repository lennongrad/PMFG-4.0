extends EnemyState

class_name EnemyDownState

var downTimer = 0

func _ready():
	self.persistent_state.animated_sprite.play("Down")
	self.persistent_state.position.y = 0
	self.persistent_state.animated_sprite.rotation_degrees.z = 0
	
func _process(_delta):
	if not self.persistent_state.lastDodgeSuccessful:
		self.persistent_state.progress_attack()
		return
	
	downTimer+=1
	
	if(downTimer > 30):
		self.persistent_state.animated_sprite.play("GetUp")
	if(downTimer > 60):
		self.persistent_state.animated_sprite.play("Rest")
	if(downTimer > 80):
		self.persistent_state.progress_attack()

func tween_completed():
	pass
