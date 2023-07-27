extends EnemyState

class_name EnemyWalkbackState

func _ready():
	self.persistent_state.animated_sprite.play("Run")
	self.persistent_state.animated_sprite.set_flip_h(true)
	#var marioPosition = self.mario.global_transform.origin + Vector3(.5, 0, 0)
	self.interpolate_property(
		self.persistent_state, "position", self.persistent_state.homePosition, .5)
	
func tween_completed():
	self.persistent_state.animated_sprite.set_flip_h(false)
	self.persistent_state.progress_attack()
