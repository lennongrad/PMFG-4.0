extends Node3D

signal pause
signal unpause

@export var debug: bool
@export var stages: Array
@export var start_stage = 0

@onready var player = $Player
@onready var partner = $Partner

var show_title = true

var strike_type
var cameraRotateDirection = 0
var cameraRotationsLeft = 0
var need_player_position = []
var encountered_enemy = null
var currentBattle = null
var paused = false
var entering_battle
var is_exiting = false

var waiting_for_menu = false

func rotate_cam(degrees):
	var need_rotation = get_tree().get_nodes_in_group("rotate_with_camera")
	for entity in need_rotation:
		entity.rotation_degrees.y = degrees

func update_need_player_position():
	need_player_position = [partner]
	for _i in $Stage/EnemySpawners.get_children():
		if(_i.has_method("pass_player")):
			need_player_position.append(_i)

# Called when the node enters the scene tree for the first time.
func _ready():
	var stage = stages[(get_node("/root/MarioRun").current_stage + start_stage) % stages.size()].instantiate()
	#var stage = load("res://scenes/overworld/stages/test_stage.tscn").instantiate()
	stage.connect("water_enter", Callable(self, "_on_stage_water_enter"))
	stage.connect("water_exit", Callable(self, "_on_stage_water_exit"))
	add_child(stage)
	get_node("/root/Global").set_main(self)
	update_need_player_position()
	var _err = self.connect("pause", Callable(player, "_on_pause"))
	_err = self.connect("pause", Callable(partner, "_on_pause"))
	_err = self.connect("unpause", Callable(player, "_on_unpause"))
	_err = self.connect("unpause", Callable(partner, "_on_unpause"))
	#add this enemy stuff to enemy spawn function
#	set_environment()
	
	if has_node("Stage/Pipes/PipeInto"):
		player.pipe_position = $Stage/Pipes/PipeInto.global_transform.origin + Vector3(0, .8, 0)
	if has_node("Stage/Pipes/PipeExit"):
		var _unused = $Stage/Pipes/PipeExit.connect("body_entered", Callable(player, "_on_pipe_detect_entry"))
		_unused = $Stage/Pipes/PipeExit.connect("body_exited", Callable(player, "on_pipe_detect_exit"))
		player.pipe_position_exit = $Stage/Pipes/PipeExit.global_transform.origin 
	
	if has_node("Stage/Pipes/PipeInto"):
		player.position = player.pipe_position
		if not debug:
			if has_node("Stage/Pipes/PipeInto"):
				player.state = player.PLAYER_STATE.PIPE
				partner.position = player.pipe_position
				partner.visible = false
			$Letterbox.toggle()
		
	if not debug and show_title:
		waiting_for_menu = true
		$Letterbox.visible = true
		$TitleScreen.visible = true
	else:
		$TitleScreen.disable()
		if not debug:
			_on_TitleScreen_done()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if paused:
		return
	for entity in need_player_position:
		entity.pass_player(player)
	
	if waiting_for_menu:
		$Status.on_hide()
	
	var activeCamera = $Player.get_camera_3d();
	if(activeCamera):
		$Camera3D.set_camera_position(activeCamera)
	#$Camera3D.target = "../Player/" + $Player.get_camera_3d()
	
	if cameraRotationsLeft == 0 and debug:
		if Input.is_action_pressed("rotate_left"):
			cameraRotateDirection = 1
			cameraRotationsLeft = 16
		elif Input.is_action_pressed("rotate_right"):
			cameraRotateDirection = -1
			cameraRotationsLeft = 16
		else:
			cameraRotateDirection = 0
	else:
		rotate_cam(PI / 64 * cameraRotateDirection)
		cameraRotationsLeft -= 1

func _on_encounter_trigger(p_encountered_enemy, p_strike_type):
	encountered_enemy = p_encountered_enemy
	strike_type = p_strike_type
	if get_node("/root/MarioRun").get_badge_value("chillout") and strike_type == "enemy":
		strike_type = "normal"
	
	paused = true
	emit_signal("pause")
	$Spin.start_spinning()
	$Player/AnimatedSprite3D.rotation_degrees.y = 0
	match strike_type:
		"hammer":
			encountered_enemy.play_hurt()
		"jump":
			$Player.play_jump()
			encountered_enemy.play_hurt()
		"enemy":
			$Player.play_hurt()
	entering_battle = true

func on_reset(did_win):
	paused = false
	emit_signal("unpause")
	self.visible = true
	$Status.visible = true
	$Spin.visible = true
	$Spin.spin_backwards()
	entering_battle = false
	
	if(did_win):
		encountered_enemy.die()
	else:
		encountered_enemy.run_away()

func get_water_level():
	var water = get_node_or_null("Stage/Water")
	if water == null:
		return 0
	return water.global_position.y

func start_exit():
	is_exiting = true

func finish_exit():
	$Spin.start_spinning()

#func set_environment():
#	if get_node_or_null("WorldEnvironment") != null:
#		$WorldEnvironment.free()
#	var world = WorldEnvironment.new()
#	world.environment = worldBackground
#	add_child(world)

func collected_item(item):
	get_node("/root/MarioRun").add_item(item)
	$Player.collect_item(item)

func open_menu():
	emit_signal("pause")
	$OverworldMenu.start_menu()

func close_menu():
	emit_signal("unpause")
	$Player.end_menu()

func start_pipe():
	var pipe = $Stage/Pipes/PipeInto
	var _err = pipe.connect("finished_growing", Callable(player, "_on_finished_growing"))
	_err = pipe.connect("finished_shrinking", Callable(self, "_on_finished_shrinking"))
	pipe.start()

func finished_pipe():
	$Stage/Pipes/PipeInto.end()
	partner.visible = true

func _on_finished_shrinking():
	player.finished_shrinking()
	$Letterbox.toggle()

func _on_Control_finishedSpinning():
	if entering_battle:
		self.visible = false
		$Spin.visible = false
		$Status.visible = false
		get_node("/root/Global").goto_scene("res://scenes/battle/Battle.tscn", 
			encountered_enemy.encounter_data, strike_type, encountered_enemy.battle_background)
	elif encountered_enemy != null:
		encountered_enemy = null
		$Camera3D.current = true
		update_need_player_position()
	elif is_exiting:
		get_node("/root/MarioRun").current_stage += 1
		get_node("/root/Global").new_main()
	else:
		if has_node("Stage/Pipes/PipeInto"):
			start_pipe()

func _on_TitleScreen_done():
	$Spin.spin_backwards()
	player.start_pipe()
	waiting_for_menu = false

func _on_stage_water_enter(body):
	if body.has_method("enter_water"):
		body.enter_water(get_water_level())

func _on_stage_water_exit(body):
	if body.has_method("exit_water"):
		body.exit_water(get_water_level())
