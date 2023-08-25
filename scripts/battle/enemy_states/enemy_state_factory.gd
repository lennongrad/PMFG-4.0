class_name EnemyStateFactory

var states

func _init():
	states = {
		"idle": EnemyIdleState,
		"jumpattack": EnemyJumpattackState,
		"swoop": EnemySwoopState,
		"ink": EnemyInkState,
		"chargedie": EnemyChargedieState,
		"walkto": EnemyWalktoState,
		"walkback": EnemyWalkbackState,
		"selfdestruct": EnemySelfDestructState,
		"down": EnemyDownState,
		"dying": EnemyDyingState,
		"slingshot": EnemySlingshotState,
		"transforming": EnemyTransformingState,
		"explosion": EnemyExplosionState
		}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
