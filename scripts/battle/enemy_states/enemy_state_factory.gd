class_name EnemyStateFactory

var states

func _init():
	states = {
		"idle": EnemyIdleState,
		"jumpattack": EnemyJumpattackState,
		"walkto": EnemyWalktoState,
		"walkback": EnemyWalkbackState,
		"down": EnemyDownState,
		"slingshot": EnemySlingshotState,
		"transforming": EnemyTransformingState,
		"dying": EnemyDyingState
}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
