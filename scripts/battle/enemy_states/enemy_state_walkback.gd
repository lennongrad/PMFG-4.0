extends EnemyState

class_name EnemyWalkbackState

func _ready():
	self.persistent_state.animated_sprite.play("Run")
	self.persistent_state.animated_sprite.set_flip_h(true)
	self.persistent_state.animated_sprite.rotation_degrees.z = 0
	#var marioPosition = self.mario.global_transform.origin + Vector3(.5, 0, 0)
	self.interpolate_property(
		self.persistent_state, "position", self.persistent_state.homePosition, .5)

func _process(_delta):
	self.persistent_state.velocity = Vector3(0,0,0)
	if not self.persistent_state.stats.flying:
		sfx.play("Footsteps", false)
	else:
		sfx.play("Flap", false)

func tween_completed():
	sfx.stop("Footsteps")
	sfx.stop("Flap")
	self.persistent_state.animated_sprite.set_flip_h(false)
	self.persistent_state.progress_attack()
