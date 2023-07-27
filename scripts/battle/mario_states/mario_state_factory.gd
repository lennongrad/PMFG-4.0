class_name HeroStateFactory

var states

func _init():
	states = {
		"idle": IdleState,
		"jumpattack": JumpattackState,
		"walkto": WalktoState,
		"walkback": WalkbackState,
		"down": DownState,
		"hammer": HammerState,
		"skip": SkipState,
		"run": RunState,
		"tattle": TattleState,
		"victory": VictoryState,
		"eat": EatState
}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
