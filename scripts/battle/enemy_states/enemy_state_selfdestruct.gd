extends EnemyState

class_name EnemySelfDestructState
var deathTimer = 0

func _ready():
	persistent_state.animated_sprite.play("Dying")
	particles.get_node("ExplosionOrange").emitting = true
	particles.get_node("ExplosionSmoke").emitting = true
	persistent_state.health = 0
	persistent_state.defeat_self = true

func _process(_delta):
	deathTimer += 1
	if deathTimer == 5:
		particles.get_node("ExplosionOrange").emitting = false
	if deathTimer == 10:
		persistent_state.unfocus_camera()
	if deathTimer == 20:
		particles.get_node("ExplosionSmoke").emitting = false
	if deathTimer > 20 and deathTimer < 30:
		persistent_state.animated_sprite.scale.y = float(29 -  deathTimer) / 10
	if deathTimer > 40:
		persistent_state.animated_sprite.visible = false
		persistent_state.progress_attack()
#	self.persistent_state.animated_sprite.play("Hurt")
#	if deathTimer < 80:
#		self.persistent_state.animated_sprite.rotation_degrees.y = deathTimer * 9
#		deathTimer += 2
#	elif deathTimer < 170:
#		self.persistent_state.animated_sprite.rotation_degrees.y = 0
#		self.persistent_state.animated_sprite.fallTimer = deathTimer - 80
#		deathTimer += 2
#	else:
#		self.persistent_state.currentlyDying = false
#
#	if self.persistent_state.experience_remaining > 0:
#		self.persistent_state.get_node("ExperienceParticles").emitting = true
#		if self.persistent_state.experience_remaining > 50:
#			self.persistent_state.get_node("..").increment_experience(4) 
#			self.persistent_state.experience_remaining -= 4
#		else:
#			self.persistent_state.get_node("..").increment_experience(1) 
#			self.persistent_state.experience_remaining -= 1
#	else:
#		self.persistent_state.get_node("ExperienceParticles").emitting = false

func tween_completed():
	pass
