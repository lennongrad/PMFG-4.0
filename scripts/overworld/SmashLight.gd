extends Control

var active = false
var progress: float: set = change_progress
var max_progress: float: set = change_max
var is_good: bool: set = set_is_good

var last_active = 0

func max_size():
	return $Base/ProgressBar.size.x

func change_progress(_progress):
	progress = _progress
	update_display()

func change_max(_max):
	max_progress = _max
	update_display()

func set_is_good(_good):
	is_good = _good
	$Base/Result/ResultBad.visible = not is_good
	$Base/Result/ResultOK.visible = is_good

func update_display():
	$Base/ProgressBar/Slider.size.x = min(progress / max_progress * max_size(), max_size())

func _process(_delta):
	if active:
		$Base.position.x += -$Base.position.x * .1
		last_active = 0
		visible = true
	else:
		$Base.position.x += (-400 - $Base.position.x) * .1
		last_active += 1
		if last_active > 30:
			visible = false
