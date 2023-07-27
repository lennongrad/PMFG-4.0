extends Sprite2D

@export var selected: bool = true

var outerVelocity = .1

func set_data(data):
	if data.name == "Jump":
		$Icon.texture = $"/root/MarioRun".get_equipped_boots().type.icon
	elif data.name == "Hammer":
		$Icon.texture = $"/root/MarioRun".get_equipped_hammer().type.icon
	else:
		$Icon.texture = data["icon"]
	$Label.text = data["name"]

func _process(delta):
	if not selected:
		$Outline.modulate.a -= $Outline.modulate.a * .2
	else:
		$Outline.modulate.a += (.5 - $Outline.modulate.a) * .2
		$Outline.rotation += outerVelocity * delta
		outerVelocity -= $Outline.rotation * .05
