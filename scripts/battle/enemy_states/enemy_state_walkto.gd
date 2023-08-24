extends EnemyState

class_name EnemyWalktoState

func _ready():
	self.persistent_state.focus_camera();
	self.persistent_state.animated_sprite.play("Run")
	var marioPosition = persistent_state.current_target.position + Vector3(.5, 0, 0)
	marioPosition.y += persistent_state.homePosition.y
	
	if persistent_state.get_current_attack().walkto_distance != 0:
		marioPosition.x += persistent_state.get_current_attack().walkto_distance
	
	self.interpolate_property(self.persistent_state, "position", marioPosition, 1)
	
func tween_completed():
	self.persistent_state.progress_attack()

func _physics_process(_delta):
	pass
