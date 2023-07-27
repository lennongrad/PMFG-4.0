
extends Resource
@export var enemies: Array
@export var flying: bool
@export var swimming: bool
@export var fly_level: float
@export var attributes: Dictionary

func _init(p_enemies = []):
	enemies = p_enemies
