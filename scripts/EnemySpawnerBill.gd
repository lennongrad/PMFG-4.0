extends Node3D

@export var encounter_data: Resource
@export var battle_background: Resource
@export var facing_right = false
@export var preload_amount = 0
@export var velocity_x = 1.5
@export var enemy_wait = 200

var player
var paused = false
var screen_visible = false

var spawn_timer = 0

func _ready():
	var _err = get_overworld().connect("pause", Callable(self, "_on_pause"))
	_err = get_overworld().connect("unpause", Callable(self, "_on_unpause"))
	player = get_overworld().get_node("Player")
	
	for i in preload_amount:
		var displacement = Vector3(-velocity_x * enemy_wait * i * .0166,0,0)
		spawn_enemy(displacement)

func _on_pause():
	paused = true

func _on_unpause():
	paused = false


func _on_visible_on_screen_notifier_3d_screen_entered():
	screen_visible = true

func _on_visible_on_screen_notifier_3d_screen_exited():
	screen_visible = false

func _process(_delta):
	if paused or screen_visible:
		return
	
	spawn_timer += 1
	if spawn_timer > enemy_wait:
		spawn_timer = 0
		spawn_enemy()


func get_overworld():
	return get_node("/root/Overworld")

func spawn_enemy(position_offset = Vector3.ZERO):
	var enemy = load("res://scenes/overworld/EnemyBill.tscn").instantiate()
	enemy.set_name("Enemy")
	enemy.player = player
	enemy.velocity_x = velocity_x
	enemy.position = position + position_offset
	enemy.face_right = facing_right
	get_overworld().add_child.call_deferred(enemy)
	
	var _err = enemy.connect("encounter_triggered", Callable(get_overworld(), "_on_encounter_trigger"))
	_err = get_overworld().connect("pause", Callable(enemy, "_on_pause"))
	_err = get_overworld().connect("unpause", Callable(enemy, "_on_unpause"))
	enemy.set_encounter(encounter_data)
	enemy.battle_background = battle_background

