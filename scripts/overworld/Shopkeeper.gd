extends Area3D

var items = []

func _ready():
	while items.size() < 10:
		var new_item = $"/root/MarioRun".get_random_item(2.5, .25, .75)
		if not items.has(new_item):
			items.append(new_item)

func get_player():
	return get_node("/root/Global").get_player()

func _process(delta):
	$Exclamation.rotate(Vector3.UP, delta * 4)
	if Input.is_action_just_pressed("jump") and $Exclamation.visible:
		$"/root/Overworld".open_shop(self)

func _on_body_entered(body):
	if get_player() == body:
		$Exclamation.rotation_degrees.y = 0
		$Exclamation.visible = true
		get_player().by_bush = true

func _on_body_exited(body):
	if get_player() == body:
		$Exclamation.visible = false
		get_player().by_bush = false
