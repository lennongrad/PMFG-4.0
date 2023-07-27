extends Node3D

@export var damage: int
@export var flipped: bool

var timeMeasure = 0
var keepBouncing = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	timeMeasure += delta * 8
	var translationValue = pow(timeMeasure, .25) * 2
	var scaleValue = translationValue * .2
	
	if keepBouncing:
		var cosValue = min(1.7, abs(cos(scaleValue * 30 + 5)) + .7)
		scaleValue *= cosValue
		if cosValue > 1.49 and timeMeasure > 3:
			keepBouncing = false
	else:
		scaleValue *= 1.7
	
	$Label.text = str(damage)
	
	$BigStar.position = Vector3(1, 1, 0) * translationValue
	$BigStar.scale = Vector3(1, 1, 1) * pow(scaleValue, .8)
	$BigStar.rotation_degrees.z = timeMeasure * 2
	$BigStar.modulate.b = abs(sin(cos(timeMeasure * .5 + 5)))
	$BigStar.modulate.a = 1 - timeMeasure / 15
	$SmallStar.position = Vector3(1.2, .7, 0) * translationValue + Vector3(0,0,.1)
	$SmallStar.scale = Vector3(.3, .3, 1) * pow(scaleValue, .5)
	$SmallStar.rotation_degrees.z = -timeMeasure * 40
	$SmallStar.modulate.a = 1 - timeMeasure / 15
	
	$Label.set_position($"../../Camera3D".unproject_position($BigStar.global_transform.origin) - Vector2(44,33))
	$Label.modulate.a = 1 - timeMeasure / 15
	
	if timeMeasure > 15:
		queue_free()
