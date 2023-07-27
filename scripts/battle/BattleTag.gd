@tool

extends Control

@export var is_visible: bool = false
@export var show_text: bool = true
@export var hp: int = 4
@export var max_hp: int = 5

func _ready():
	pass

func _process(_delta):
	if not is_visible:
		modulate.a -= modulate.a * .2
	else:
		modulate.a += (1 - modulate.a) * .2
	if show_text:
		$Label.text = str(hp)
	else:
		$Label.text = ""
	$ProgressBar.max_value = max_hp
	$ProgressBar.value = max_hp - hp
