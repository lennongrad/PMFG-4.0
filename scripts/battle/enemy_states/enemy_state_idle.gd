extends EnemyState

class_name EnemyIdleState
var damageTimer = 0

func _ready():
	self.persistent_state.animated_sprite.play("Rest")

func _process(delta):
	self.velocity = Vector3(0,0,0)
	self.persistent_state.animated_sprite.rotation_degrees.z = 0
	self.persistent_state.position = self.persistent_state.homePosition

	if self.persistent_state.in_water() and not self.persistent_state.stats.flying:
		self.persistent_state.get_node("Circles").visible = true
	else:
		self.persistent_state.get_node("Circles").visible = false
	
	if self.persistent_state.hurt_particles.isPlaying:
		damageTimer += delta
		self.persistent_state.animated_sprite.play("Hurt")
		if not self.persistent_state.stats.attributes.has("balloons"):
			var f_translate = self.persistent_state.originalTranslation + Vector3(cos(damageTimer * 32) * .025,0,0)
			f_translate += Vector3(0, abs(sin(damageTimer * 8)) * .2 / pow(damageTimer + 1, 1.25), 0)
			self.persistent_state.animated_sprite.position = f_translate
		else:
			self.persistent_state.get_node("Sprite2D/Balloons").depress()
	else:
		damageTimer = 0
		self.persistent_state.get_node("Sprite2D/Balloons").unpress()
		if self.persistent_state.attackAnimationCounter == 0:
			self.persistent_state.animated_sprite.play("Rest")
		self.persistent_state.animated_sprite.position = self.persistent_state.originalTranslation
	if not self.persistent_state.stats.attributes.has("balloons"):
		self.persistent_state.get_node("Sprite2D/Balloons").visible = false
	else:
		self.persistent_state.get_node("Sprite2D/Balloons").visible = true

func tween_completed():
	pass
