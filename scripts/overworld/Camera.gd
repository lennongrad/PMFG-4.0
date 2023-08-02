extends Camera3D

@export var keep_y: bool = true

@onready var base_position = $"../BasePosition"

var currently_tracking = null
var fully_tracked = false

func set_camera_position(camera):
	currently_tracking = camera
	#var tween = create_tween()
	#tween.tween_property(self, "position", camera.position, .1)
	#fully_tracked = false
	#tween.tween_callback(tween_complete)

func tween_complete():
	fully_tracked = true

func reset_position():
	set_camera_position(base_position)

func _process(_delta):
	if true:#fully_tracked:
		position += (currently_tracking.global_position - position) * .2
		rotation_degrees += (currently_tracking.rotation_degrees - rotation_degrees) * .2
		cull_mask = currently_tracking.cull_mask
		if(keep_y):
			position.y = base_position.position.y

func _ready():
	reset_position()
