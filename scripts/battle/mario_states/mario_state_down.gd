extends State

class_name DownState

var downTimer = 0

func _ready():
	self.hero.get_node("Sprite2D").play("Down")
	self.hero.position.y = 0
	
func _process(_delta):
	downTimer+=1
	
	if(downTimer > 30):
		self.hero.get_node("Sprite2D").play("GetUp")
	if(downTimer > 60):
		self.hero.get_node("Sprite2D").play("Rest")
	if(downTimer > 80):
		self.hero.progress_attack()

func tween_completed():
	pass
