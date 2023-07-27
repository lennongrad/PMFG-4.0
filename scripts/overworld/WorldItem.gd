extends CharacterBody3D

@export var item: Resource

signal collected(item_type)

var player
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector3((1 - float(randi() % 2) * 2) * .25, 1.5, (1 - float(randi() % 2) * 2) * .25)

func _physics_process(delta):
	if is_on_floor():
		velocity.x -= velocity.x * .05
		velocity.z -= velocity.z * .05
	velocity.y -= delta * 4
	set_velocity(velocity)
	set_up_direction(Vector3(0, 1, 0))
	move_and_slide()
	velocity = velocity

func _process(_delta):
	$Sprite3D.texture = item.icon_texture
	timer += 1
	if (timer > 1250 and timer % 16 < 4) or (timer > 1500 and timer % 8 < 4):
		visible = false
	else:
		visible = true
	if (timer > 1600):
		queue_free()

func _on_Area_body_entered(body):
	if body == player:
		emit_signal("collected", item)
		queue_free()
