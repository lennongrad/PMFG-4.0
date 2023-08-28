extends StaticBody3D

@export var translation_y: float = 0
@export var is_decoration = false

var activated = false
var timer = 0.0
var given_item = false
var item_type
@onready var original_translation = $"..".global_position
@onready var faces = [$Face1, $Face2, $Face3, $Face4]
@onready var blocks = [$Block1, $Block2, $Block3, $Block4]
@onready var used_sides = blocks + [$Top, $Bottom]

@export var coin_count: int

func get_player():
	return $"../../../../Player"

func _ready():
	item_type = $"/root/MarioRun".get_random_item(1, .25, .5)
	if (item_type != null and item_type.is_badge):
		for block in used_sides:
			block.mesh = load("res://textures/blocks/UsedRed.tres")
		for face in faces:
			face.get_node("MeshInstance3D").mesh = load("res://textures/blocks/QBlockRed.tres")
	elif (item_type != null and item_type.is_weapon):
		for block in used_sides:
			block.mesh = load("res://textures/blocks/UsedBlue.tres")
		for face in faces:
			face.get_node("MeshInstance3D").mesh = load("res://textures/blocks/QBlockBlue.tres")
	else:
		for block in used_sides:
			block.mesh = load("res://textures/blocks/UsedYellow.tres")
		for face in faces:
			face.get_node("MeshInstance3D").mesh = load("res://textures/blocks/QBlockYellow.tres")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if translation_y == .15:
		for node in blocks + used_sides:
			node.cast_shadow = 1
	if activated:
		timer += 3
		if timer < 100 and timer > 0:
			position.y = translation_y +  sin(timer / 100 * PI) * .25
			for face in faces:
				face.rotation_degrees.x = timer / 100 * 90
			if timer > 50 and not given_item:
				given_item = true
				var item = load("res://scenes/overworld/OverworldItem.tscn").instantiate()
				item.item = item_type
				item.player = get_player()
				$"../../..".add_child(item)
				item.connect("collected", Callable($"../../../..", "collected_item"))
				item.position = original_translation + Vector3(0, .33 + translation_y, 0)
				
				for _i in range(0, coin_count):
					var coin = load("res://scenes/overworld/OverworldCoin.tscn").instantiate()
					$"../../..".add_child(coin)
					coin.position = original_translation + Vector3(0, .33 + translation_y, 0)
			if timer > 35 and timer < 50 and not given_item:
				$Particles.emitting = true
			else:
				$Particles.emitting = false
		elif timer > 100:
			for face in faces:
				face.visible = false
			activated = false

func start_timer():
	get_player().get_node("SFX").play("Bonk")
	if not activated:
		timer = 0.0
		for block in blocks:
			block.visible = true
	elif timer > 50 and not given_item:
		timer = 50.0 - timer
	activated = true

func _on_Area_body_entered(body):
	if is_decoration:
		return
	if body == get_player(): #and body.velocity.y > 0:
		start_timer()

func _on_Area_area_entered(area):
	if is_decoration:
		return
	if area == get_player().get_node("HammerArea"):
		start_timer()
