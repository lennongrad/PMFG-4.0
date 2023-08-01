extends State

class_name TattleState

var slide_puzzle

enum TATTLE_STATES {WIN, LOSS, UNKNOWN}
var state = TATTLE_STATES.UNKNOWN
var timer = 0

func _ready(): 
	hero.get_node("Sprite2D").play("Skip")
	
	slide_puzzle = load("res://scenes/battle/SlidePuzzle.tscn").instantiate()
	slide_puzzle.enemy = target.stats
	hero.add_child(slide_puzzle)
	slide_puzzle.connect("finished_loss", Callable(self, "on_loss"))
	slide_puzzle.connect("finished_win", Callable(self, "on_win"))

func on_loss():
	state = TATTLE_STATES.LOSS
	timer = 0
	
func on_win():
	state = TATTLE_STATES.WIN
	timer = 0
	$"/root/MarioRun".tattle_enemy(target.stats)

func _physics_process(_delta):
	var offset = Vector2(75, 300)
	timer += 1
	match state:
		TATTLE_STATES.LOSS:
			hero.get_node("Sprite2D").play("Hurt")
			offset = Vector2(75, 900)
			if timer > 40:
				hero.progress_attack()
		TATTLE_STATES.WIN:
			hero.get_node("Sprite2D").play("Victory")
			offset = Vector2(75, 900)
			if timer > 40:
				hero.progress_attack()
	var slide_position = slide_puzzle.get_position() 
	slide_position -= (slide_position - hero.get_node("../Camera3D").unproject_position(hero.get_position()) + offset) * .1
	slide_puzzle.set_position(slide_position)

func tween_completed():
	pass
