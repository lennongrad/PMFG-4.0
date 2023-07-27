extends EnemyState

class_name EnemyDyingState
var deathTimer = 0

func _ready():
	self.persistent_state.animated_sprite.play("Hurt")
	self.persistent_state.get_node("Sprite2D/Balloons").pop()

func _process(_delta):
	self.persistent_state.animated_sprite.play("Hurt")
	if deathTimer < 80:
		self.persistent_state.animated_sprite.rotation_degrees.y = deathTimer * 9
		deathTimer += 2
	elif deathTimer < 170:
		self.persistent_state.animated_sprite.rotation_degrees.y = 0
		self.persistent_state.animated_sprite.fallTimer = deathTimer - 80
		deathTimer += 2
	else:
		self.persistent_state.currentlyDying = false
	
	if self.persistent_state.experience_remaining > 0:
		self.persistent_state.get_node("ExperienceParticles").emitting = true
		if self.persistent_state.experience_remaining > 50:
			self.persistent_state.get_node("..").increment_experience(4) 
			self.persistent_state.experience_remaining -= 4
		else:
			self.persistent_state.get_node("..").increment_experience(1) 
			self.persistent_state.experience_remaining -= 1
	else:
		self.persistent_state.get_node("ExperienceParticles").emitting = false

func tween_completed():
	pass
