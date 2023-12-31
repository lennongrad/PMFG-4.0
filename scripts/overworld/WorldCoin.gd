extends CharacterBody3D

@export var editor: bool

var rng = RandomNumberGenerator.new()

signal coin_gain(c_type)

var baseaVelocity = Vector3(0,0,0)
var timer
var type = "coin"

func set_type(new_type):
	type = new_type
	$CoinSprite.visible = type == "coin"
	$FlowerSprite.visible = type == "flower"
	$HeartSprite.visible = type == "heart"

func random_type():
	var chance = rng.randi_range(0,3)
	if chance == 0:
		set_type("coin")
	elif chance == 1:
		set_type("flower")
	else:
		set_type("heart")

# Called when the node enters the scene tree for the first time.
func _ready():
	baseaVelocity.x = 25 - (randi() % 50)
	baseaVelocity.z = 25 - (randi() % 50)
	baseaVelocity /= 25
	baseaVelocity.y = 1.5
	timer = -(randi() % 50) - 1
	if(get_node("/root/Global").get_player() != null):
		var _unused = connect("coin_gain", Callable(get_node("/root/Global").get_player(), "collected_coin"))

func _physics_process(delta):
	if timer < 0:
		return
	if is_on_floor():
		baseaVelocity.x -= baseaVelocity.x * .05
		baseaVelocity.z -= baseaVelocity.z * .05
	else:
		baseaVelocity.x += float(1 - randi() % 2) * .01
		baseaVelocity.z += float(1 - randi() % 2) * .01
	baseaVelocity.y -= delta * 4
	set_velocity(baseaVelocity)
	set_up_direction(Vector3(0, 1, 0))
	move_and_slide()

func _process(_delta):
	if editor:
		return
	timer += 1
	if (timer > 250 and int(timer) % 16 < 4) or (timer > 500 and int(timer) % 8 < 4) or (timer < 0):
		visible = false
	else:
		visible = true
	if (timer > 600):
		queue_free()

func _on_Area_body_entered(body):
	if body == get_node("/root/Global").get_player() and (timer > 0 or editor):
		emit_signal("coin_gain", type)
		queue_free()
