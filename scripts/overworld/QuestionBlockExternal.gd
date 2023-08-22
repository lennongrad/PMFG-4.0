@tool

extends Node3D

@export var is_decoration = false
@export var coin_count: int
@export var distance: float = .9: set = change_distance

func change_distance(p_distance):
	distance = p_distance
	if has_node("QuestionBlock"):
		$QuestionBlock.position.y = distance + .15
		$QuestionBlock.translation_y = distance + .15
		if distance == 0:
			$Shadow.visible = false



func _ready():
	$QuestionBlock.coin_count = coin_count
	$QuestionBlock.is_decoration = is_decoration
