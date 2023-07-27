extends State

class_name RunState

func _ready():
	hero.get_node("Sprite2D").play("Rest")

func _process(_delta):
	hero.progress_attack()

func tween_completed():
	pass
