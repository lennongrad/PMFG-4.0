@tool

extends Control

@export var experience_count: int: set = change_experience
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_experience(p_exp):
	experience_count = p_exp
	
	for i in range(0, $NinePatchRect/Panel.get_child_count()):
		get_child(i).queue_free()
	#res://sprites/other/expframes.tres
