extends EnemyState

class_name EnemyWalktoState

func _ready():
	self.persistent_state.focus_camera();
	self.persistent_state.animated_sprite.play("Run")
	var marioPosition = self.mario.position + Vector3(.5, 0, 0)
	self.interpolate_property(self.persistent_state, "position", marioPosition, 1)
	
func tween_completed():
	self.persistent_state.progress_attack()

func _physics_process(_delta):
	pass
