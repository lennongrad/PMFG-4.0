extends Node3D

var nice_timer = 0
var miss_timer = 0
var good_timer = 0 
var lucky_timer = 0

func start_nice(direction):
	if direction == -1:
		$Nice.rotation_degrees.y = 180
	else:
		$Nice.rotation_degrees.y = 0
	$Nice.emitting = true
	nice_timer = 3

func start_miss(direction):
	if direction == -1:
		$Miss.rotation_degrees.y = 180
	else:
		$Miss.rotation_degrees.y = 0
	$Miss.emitting = true
	miss_timer = 3

func start_good(direction):
	if direction == -1:
		$Good.rotation_degrees.y = 180
	else:
		$Good.rotation_degrees.y = 0
	$Good.emitting = true
	good_timer = 3

func start_lucky(direction):
	if direction == -1:
		$Lucky.rotation_degrees.y = 180
	else:
		$Lucky.rotation_degrees.y = 0
	$Lucky.emitting = true
	lucky_timer = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	nice_timer -= 1
	if nice_timer == 0:
		$Nice.emitting = false
	miss_timer -= 1
	if miss_timer == 0:
		$Miss.emitting = false
	good_timer -= 1
	if good_timer == 0:
		$Good.emitting = false
	lucky_timer -= 1
	if lucky_timer == 0:
		$Lucky.emitting = false
