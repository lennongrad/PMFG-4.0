@tool

extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_set_text(new_text):
	text = new_text

func _process(_delta):
	var new_rect_size = Vector3(size.x, size.y, 0) * Vector3(.5, .333, 0)
	$Clouds/Clouds.process_material.set_emission_box_extents(new_rect_size)
	$Clouds/Clouds.position = size / 2
