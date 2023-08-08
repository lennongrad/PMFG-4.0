extends Camera3D

@export var keep_y: bool = true

@onready var base_position = $"../BasePosition"

var currently_tracking = null
var fully_tracked = false
var shake_timer = 0

func set_camera_position(camera):
	currently_tracking = camera

func tween_complete():
	fully_tracked = true

func shake(time = 15):
	shake_timer = time

func reset_position():
	set_camera_position(base_position)

func _process(_delta):
	
	position += (currently_tracking.global_position - position) * .3
	shake_timer -= 1
	if shake_timer > 0:
		position.x += sin(floor(shake_timer) * 2)
	
	rotation_degrees += (currently_tracking.rotation_degrees - rotation_degrees) * .3
	$"..".rotate_cam(rotation_degrees.y)
	cull_mask = currently_tracking.cull_mask
	if(keep_y):
		position.y = base_position.position.y

func _ready():
	reset_position()
