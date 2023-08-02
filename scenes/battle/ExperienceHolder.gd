@tool

extends Control

@export var experience_count: int: set = change_experience
@export var centered: bool: set = change_centered

var max_size = 0
var max_experience = 0

func _ready():
	pass # Replace with function body.

func _process(_delta):
	scale = (((Vector2(get_viewport().get_size()) - Vector2(1000, 600)) * 1.75 + Vector2(1000, 600))
	* Vector2(.001, .001666))
	if centered:
		scale *= 1.2
		$Text.modulate.a += (1 - $Text.modulate.a) * .1
	else:
		$Text.modulate.a = 0
	if experience_count > max_experience:
		max_experience = experience_count
	$Text/Count.text = str(max_experience)

func change_centered(p_centered):
	if not has_node("NinePatchRect"):
		return
	centered = p_centered
	$NinePatchRect.size.x = max_size
	$NinePatchRect.position.x = -$NinePatchRect.size.x
	$NinePatchRect.position.y = -35
	if centered:
		$NinePatchRect.position /= 2
	
	if centered:
		$NinePatchRect/Panel/SpriteHolder.anchor_left = 0
		$NinePatchRect/Panel/SpriteHolder.anchor_right = 0
	else:
		$NinePatchRect/Panel/SpriteHolder.anchor_left = 1
		$NinePatchRect/Panel/SpriteHolder.anchor_right = 1

func change_experience(p_exp):
	if not has_node("NinePatchRect"):
		return
	
	experience_count = p_exp
	if experience_count == 0:
		visible = false
		return
	else:
		visible = true
	
	var f_size = (15 * (int(experience_count) % 10) + 
		28 * floor((experience_count) / 10) + 13)
	if not centered or f_size > max_size:
		max_size = f_size
	$NinePatchRect.size.x = max_size
	$NinePatchRect.position.x = -$NinePatchRect.size.x
	$NinePatchRect.position.y = -$NinePatchRect.size.y
	if p_exp < 10:
		$NinePatchRect.size.y = 24
	else:
		$NinePatchRect.size.y = 36
	if centered:
		$NinePatchRect.position /= 2
	
	for i in range(0, $NinePatchRect/Panel/SpriteHolder.get_child_count()):
		$NinePatchRect/Panel/SpriteHolder.get_child(i).queue_free()
	
	var direction = -1
	if centered:
		direction = 1
	
	for i in range(0, floor(experience_count / 10)):
		var sprite = AnimatedSprite2D.new()
		$NinePatchRect/Panel/SpriteHolder.add_child(sprite)
		sprite.frames = load("res://sprites/other/expframes.tres")

		sprite.play("spin")
		sprite.scale = Vector2(.7, .7)
		sprite.position = Vector2(direction * (28 * i + 20), -18)
	
	for i in range(0, experience_count % 10):
		var sprite = AnimatedSprite2D.new()
		$NinePatchRect/Panel/SpriteHolder.add_child(sprite)
		sprite.frames = load("res://sprites/other/expframes.tres")
		sprite.play("spin")
		sprite.scale = Vector2(.35, .35)
		sprite.position = Vector2(direction * (15 * i + 13 + 28 * floor(experience_count / 10)), -12)
