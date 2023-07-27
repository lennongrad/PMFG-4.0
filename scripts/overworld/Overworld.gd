extends Node3D

signal pause
signal unpause

@export var debug: bool
@export var worldBackground: Environment

@onready var player = $Player
@onready var partner = $Partner

var water_level = 0.586

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
	player.rotate_y(degrees)
	for entity in need_player_position:
		entity.rotate_y(degrees)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Global").set_main(self)
	need_player_position.append(partner)
	need_player_position.append($EnemySpawner)
	need_player_position.append($EnemySpawner2)
	need_player_position.append($EnemySpawner3)
	var _err = self.connect("pause", Callable(player, "_on_pause"))
	_err = self.connect("pause", Callable(partner, "_on_pause"))
	_err = self.connect("unpause", Callable(player, "_on_unpause"))
	_err = self.connect("unpause", Callable(partner, "_on_unpause"))
	#add this enemy stuff to enemy spawn function
	set_environment()
	
	if has_node("Stage/PipeInto"):
		player.pipe_position = $Stage/PipeInto.global_transform.origin + Vector3(0, .4, 0)
	if has_node("Stage/PipeExit"):
		var _unused = $Stage/PipeExit.connect("body_entered", Callable(player, "_on_pipe_detect_entry"))
		_unused = $Stage/PipeExit.connect("body_exited", Callable(player, "on_pipe_detect_exit"))
		player.pipe_position_exit = $Stage/PipeExit.global_transform.origin 
	if not debug:
		if has_node("Stage/PipeInto"):
			partner.position = player.pipe_position
			partner.visible = false
		waiting_for_menu = true
		$Letterbox.toggle()
	else:
		$TitleScreen.disable()

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
		activeCamera.current = true;
	#$Camera3D.target = "../Player/" + $Player.get_camera_3d()
	
	if cameraRotationsLeft == 0:
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

var randomTimer = 0

func _on_encounter_trigger(p_encountered_enemy, p_strike_type):
	encountered_enemy = p_encountered_enemy
	strike_type = p_strike_type
	paused = true
	emit_signal("pause")
	$Spin.start_spinning()
	match strike_type:
		"hammer":
			encountered_enemy.play_hurt()
		"jump":
			$Player.play_jump()
			encountered_enemy.play_hurt()
		"enemy":
			$Player.play_hurt()
	entering_battle = true

func on_reset(_data):
	paused = false
	emit_signal("unpause")
	self.visible = true
	set_environment()
	$Status.visible = true
	$Spin.visible = true
	$Spin.spin_backwards()
	entering_battle = false
	encountered_enemy.die()

func start_exit():
	is_exiting = true

func finish_exit():
	$Spin.start_spinning()

func set_environment():
	if get_node_or_null("WorldEnvironment") != null:
		$WorldEnvironment.free()
	var world = WorldEnvironment.new()
	world.environment = worldBackground
	add_child(world)

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
	var pipe = $Stage/PipeInto
	var _err = pipe.connect("finished_growing", Callable(player, "_on_finished_growing"))
	_err = pipe.connect("finished_shrinking", Callable(self, "_on_finished_shrinking"))
	pipe.start()

func finished_pipe():
	$Stage/PipeInto.end()
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
		need_player_position = [partner]
	elif is_exiting:
		pass
	else:
		if has_node("Stage/PipeInto"):
			start_pipe()

func _on_Water_body_exited(body):
	if body.has_method("exit_water"):
		body.exit_water()

func _on_Water_body_entered(body):
	if body.has_method("enter_water"):
		body.enter_water()

func _on_TitleScreen_done():
	$Spin.spin_backwards()
	player.start_pipe()
	waiting_for_menu = false
