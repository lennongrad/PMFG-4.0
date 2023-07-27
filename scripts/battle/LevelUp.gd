extends Control

var current_choice = 0
var num_choices = 3
var timer = 0
var active = false
var selected = false
var velocity = 0

func _ready():
	change_choice(0)
	$Confetti/GPUParticles2D.emitting = false
	modulate.a = 0
	timer = 150

func activate():
	timer = 0
	velocity = 0
	selected = false
	active = true
	$Confetti/GPUParticles2D.emitting = true
	$Choices.position.y = -100
	velocity = 8
	
	$Choices/HP.left_side = $"/root/MarioRun".get_max_hp(load("res://stats/herostats/mario.tres"))
	$Choices/FP.left_side = $"/root/MarioRun".get_max_fp()
	$Choices/BP.left_side = $"/root/MarioRun".get_max_bp()
	$Choices/HP.right_side = $"/root/MarioRun".get_max_hp(load("res://stats/herostats/mario.tres")) + 3
	$Choices/FP.right_side = $"/root/MarioRun".get_max_fp() + 3
	$Choices/BP.right_side = $"/root/MarioRun".get_max_bp() + 3

func deactivate():
	timer = 0
	active = false
	$Confetti/GPUParticles2D.emitting = false

func change_choice(direction):
	current_choice += direction
	if current_choice > (num_choices - 1):
		current_choice = 0
	if current_choice < 0:
		current_choice = num_choices - 1
	
	$Choices/HP.modulate.v = .3
	$Choices/FP.modulate.v = .3
	$Choices/BP.modulate.v = .3
	match current_choice:
		0: 
			$Choices/Spotlight/Polygon2d.rotation_degrees = 162.3;
			$Choices/HP.modulate.v = 1
		1: 
			$Choices/Spotlight/Polygon2d.rotation_degrees = 131.6;
			$Choices/FP.modulate.v = 1
		2: 
			$Choices/Spotlight/Polygon2d.rotation_degrees = 101.4;
			$Choices/BP.modulate.v = 1
	$Choices/Spotlight/Polygon2d.modulate.a = 0

func select():
	selected = true
	timer = 0
	match current_choice:
		0: $"/root/MarioRun".add_bonus("hp")
		1: $"/root/MarioRun".add_bonus("fp")
		2: $"/root/MarioRun".add_bonus("bp")

func _process(_delta):
	if active:
		timer += 1
		if not selected:
			if timer < 140:
				if $Choices.position.y > 270 and velocity > 0:
					velocity *= -.3
				$Choices.position.y += velocity
				velocity += .1
				$Choices/Spotlight/Polygon2d.modulate.a = 0
			else:
				if Input.is_action_just_pressed("ui_right"):
					change_choice(1)
				if Input.is_action_just_pressed("ui_left"):
					change_choice(-1)
				if Input.is_action_just_pressed("jump"):
					select()
				$Choices.position.y = 270
				$Choices/HP.position.y = 13
				$Choices/FP.position.y = 13
				$Choices/BP.position.y = 13
				$Choices/HP.modulate.a = 1
				$Choices/FP.modulate.a = 1
				$Choices/BP.modulate.a = 1
				$Choices/HP.scale = Vector2(1, 1)
				$Choices/FP.scale = Vector2(1, 1)
				$Choices/BP.scale = Vector2(1, 1)
				$Choices/Spotlight.position.y = 0
				$Choices/Spotlight.modulate.a = 1
		else:
			var difference = 9
			var alpha = 1
			if timer > 50:
				alpha = max(0, 1 - float(timer - 50) / 50)
				if timer == 100:
					$"..".finish_level_up()
			elif (timer % 16) < 2:
				alpha = .2
			$Choices.position.y -= difference
			match current_choice:
				0: 
					$Choices/HP.position.y += difference
					$Choices/HP.modulate.a = alpha
					$Choices/HP.scale = Vector2(1, 1) * (1 + float(timer) / 150)
				1: 
					$Choices/FP.position.y += difference
					$Choices/FP.modulate.a = alpha
					$Choices/FP.scale = Vector2(1, 1) * (1 + float(timer) / 150)
				2: 
					$Choices/BP.position.y += difference
					$Choices/BP.modulate.a = alpha
					$Choices/BP.scale = Vector2(1, 1) * (1 + float(timer) / 150)
			$Choices/Spotlight.position.y += difference
			$Choices/Spotlight.modulate.a -= $Choices/Spotlight.modulate.a * .1
	$Choices/Spotlight/Polygon2d.modulate.a += (1 - $Choices/Spotlight/Polygon2d.modulate.a) * .05
	
	if active:
		modulate.a += (1 - modulate.a) * .05
	else:
		modulate.a += (-modulate.a) * .05
