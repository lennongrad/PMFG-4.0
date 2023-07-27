extends Control

var hide_timer = 0
var fp_visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_hide():
	hide_timer = 100

func unhide():
	hide_timer = 0

func show_fp():
	fp_visible = true

func hide_fp():
	fp_visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Status.scale = (((Vector2(get_viewport().get_size()) - Vector2(1000, 600)) * .5 + Vector2(1000, 600))
	* Vector2(.001, .001666))
	$StatusEXP.scale = $Status.scale
	$StatusFP.scale = $Status.scale
	
	# must be changed when partner swapping implemented
	$Status/HP/Label2.text = (str($"/root/MarioRun".get_hp(load("res://stats/herostats/mario.tres"))) 
		+ "/" + str($"/root/MarioRun".get_max_hp(load("res://stats/herostats/mario.tres"))))
	$StatusFP/HP2/Label2.text = (str($"/root/MarioRun".get_partner_hp()) 
		+ "/" + str($"/root/MarioRun".get_partner_max_hp()))
	$StatusFP/FP/Label2.text = (str($"/root/MarioRun".get_fp()) 
		+ "/" + str($"/root/MarioRun".get_max_fp()))
	$StatusEXP/Coins/Value.text = "x" + str($"/root/MarioRun".get_coins())
	$StatusEXP/EXP/Value.text = "x" + str($"/root/MarioRun".get_experience())
	
	hide_timer += 1
	if hide_timer > 75:
		position.y += (-100 - position.y) * .1
	else:
		position.y += (-position.y) * .1
	
	if fp_visible:
		$StatusFP.modulate.a += (1 - $StatusFP.modulate.a) * .1
	else:
		$StatusFP.modulate.a -= $StatusFP.modulate.a * .1
