extends Control

@export var item: Resource

var timer = 0
var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_item(p_item):
	item = p_item
	$Item/Item.texture = item.icon
	$Description/Textbox/Label.text = item.description
	$Description/Title/Title/Label.text = item.name
	timer = 0
	active = true

func disable():
	active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Item/Cloud.scale = (((Vector2(get_viewport().get_size()) - Vector2(1000, 600)) * .9 + Vector2(1000, 600))
	* Vector2(.001, .001666))
	
	timer += .05
	$Item/Rays.rotation = timer
	if active:
		$Item/Rays.modulate.a += (.2 - $Item/Rays.modulate.a) * .025
	else:
		$Item/Rays.modulate.a -= $Item/Rays.modulate.a * .025
