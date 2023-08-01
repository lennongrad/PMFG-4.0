@tool

extends Node3D

@export var encounter_data: Resource: set = set_encounter
@export var size: Vector3: set = set_size
@export var battle_background: Resource

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		spawn_enemy()
		$Preview.visible = false
	else:
		$Preview.visible = true

func get_overworld():
	return get_node("/root/Overworld")

func spawn_enemy():
	if has_node("Enemy"):
		return
	var enemy = load("res://scenes/overworld/Enemy.tscn").instantiate()
	enemy.set_name("Enemy")
	enemy.enemy_bounds = $Bounds
	enemy.water_level = get_overworld().get_water_level()
	add_child(enemy)
	
	var _err = $Enemy.connect("encounter_triggered", Callable(get_overworld(), "_on_encounter_trigger"))
	_err = get_overworld().connect("pause", Callable($Enemy, "_on_pause"))
	_err = get_overworld().connect("unpause", Callable($Enemy, "_on_unpause"))
	$Enemy.set_encounter(encounter_data)
	$Enemy.battle_background = battle_background

func _process(_delta):
	pass

func set_size(p_size):
	size = p_size
	if not has_node("Bounds"):
		return
	$Bounds/CollisionShape3D.shape = BoxShape3D.new()
	$Bounds/CollisionShape3D.shape.size = size / 2

func set_encounter(p_encounter):
	encounter_data = p_encounter
	if not has_node("Preview"):
		return
	$Preview.frames = encounter_data.enemies[0].frames
	$Preview.position.y = .32 + encounter_data.fly_level
	if has_node("Enemy"):
		$Enemy.set_encounter(encounter_data)

func pass_player(p_player):
	player = p_player
	$Enemy.player = player

func on_rotate_y(degrees):
	if has_node("Enemy"):
		$Enemy.rotate_y(degrees)

func _on_Bounds_body_exited(body):
	if has_node("Enemy"):
		if body == $Enemy:
			$Enemy.return_to_bounds()
		if body == player:
			$Enemy.player_exited()

func _on_Bounds_body_entered(body):
	if body == player and has_node("Enemy"):
		$Enemy.player_entered()
