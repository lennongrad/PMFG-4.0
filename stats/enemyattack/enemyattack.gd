extends Resource
@export var steps: Array[String]
@export var attributes: Dictionary
@export var walkto_distance = 0.0

func _init(p_steps: Array[String] = []):
	steps = p_steps
