extends EnemyState

class_name EnemyTransformingState

var transformTimer = 0
var down

func _ready():
	self.persistent_state.get_node("Sprite2D/Balloons").pop()
	self.persistent_state.focus_camera()

func _physics_process(_delta):
	self.persistent_state.move_and_slide()
	transformTimer += 1
	if down:
		if transformTimer < 50:
			self.persistent_state.animated_sprite.play("Down")
		elif transformTimer < 100:
			self.persistent_state.animated_sprite.play("GetUp")
		else:
			self.persistent_state.change_state("idle")
	else:
		if transformTimer < 75:
			pass
		elif transformTimer < 100:
			self.persistent_state.get_node("Exclamation").visible = true
		elif transformTimer < 150:
			self.persistent_state.get_node("Exclamation").visible = false
		elif transformTimer < 200:
			self.persistent_state.animated_sprite.play("Hurt")
		else:
			self.animated_sprite.get_node("Decoration/Wings").play("SlowFlap")
			self.persistent_state.velocity.y -= .1

func tween_completed():
	pass

func area_body_entered(body):
	if body == self.floorMesh:
		down = true
		transformTimer = 0
		self.persistent_state.velocity.y = 0
		self.persistent_state.transform_to_enemy()
		self.persistent_state.unfocus_camera()
