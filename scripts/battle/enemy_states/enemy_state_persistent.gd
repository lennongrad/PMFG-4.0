extends CharacterBody3D

@export var stats: Resource
@export var guarding: bool = false
@export var icon: CompressedTexture2D
@export var is_idle: bool = false
@export var isSelected: bool = false

@onready var camera = $Camera3D
@onready var pointer = $Pointer
@onready var animated_sprite = $Sprite2D
@onready var slingshot_ammo = $SlingshotAmmo
@onready var homePosition = global_transform.origin
@onready var originalHomePosition = global_transform.origin
@onready var slingshotHomePosition = slingshot_ammo.position
@onready var mario = $"../Mario"
@onready var partner = $"../Partner"
@onready var hurt_particles = $HurtParticles
@onready var originalTranslation = $Sprite2D.position
@onready var marioRun = get_node("/root/MarioRun")

var health
var setToDie = false

var state
var battleTag
var state_factory
var slingshotVelocity = Vector3()
var attackAnimationCounter = 0
var currentAttack = 0
var lastDodgeSuccessful = true
var currentlyDying = false
var currentlyTransforming = false
var is_in_water
var experience_remaining = 0
var dodging = 0
var defeat_self = false

var randomStartTimer = Timer.new()

func _ready():
	randomize()
	animated_sprite.set_frames(stats.frames)
	animated_sprite.play("Rest")

	experience_remaining = stats.experience

	if stats.flying:
		homePosition.y += .75
	position = homePosition

	state_factory = EnemyStateFactory.new()
	change_state("idle")

	battleTag = load("res://scenes/battle/BattleTag.tscn").instantiate()
	battleTag.set_name("battleTag")
	$"..".call_deferred("add_child", battleTag)

	health = stats.health

	currentAttack = randi() % stats.attacks.size()

# Input code was placed here for tutorial purposes.
func _process(_delta):
	pointer.visible = isSelected
	if battleTag != null:
		battleTag.is_visible = is_idle
		battleTag.max_hp = stats.health
		battleTag.hp = health
		battleTag.show_text = $"/root/MarioRun".is_tattled(stats)
		battleTag.set_position(get_viewport().get_camera_3d().unproject_position(get_position()) - Vector2(45, 0))

func change_state(new_state_name):
	if(state != null):
		state.queue_free()
	state = state_factory.get_state(new_state_name).new()
	state.setup(Callable(self, "change_state"), Callable(self, "progress_attack"), self,
		mario, partner, $"../Floor")
	state.name = "current_state"
	add_child(state)

func get_current_attack():
	if currentAttack == -1:
		return stats.firstStrikeAttack
	else:
		return stats.attacks[currentAttack]

func register_damage(target, damage, effectiveness, showHurt = {}):
	$"..".register_damage(target, damage, effectiveness, showHurt)
	if effectiveness == "NICE":
		lastDodgeSuccessful = true
	else:
		lastDodgeSuccessful = false

func attack():
	if attackAnimationCounter == 0:
		progress_attack()

func progress_attack():
	if get_current_attack().steps.size() > attackAnimationCounter:
		change_state(get_current_attack().steps[attackAnimationCounter])
		attackAnimationCounter += 1
	else:
		attackAnimationCounter = 0
		unfocus_camera()
		change_state("idle")
		if currentAttack == -1:
			$"..".start_mario_turn()
		else:
			$"..".next_enemy_turn(0)
		currentAttack = (currentAttack + 1) % stats.attacks.size()

func firstStrike():
	currentAttack = -1
	progress_attack()

func take_damage(damage, effectiveness, attributes):
	match effectiveness:
		"NICE":
			$FeedbackParticle.start_nice(1)
		"MISS":
			$FeedbackParticle.start_miss(1)
			$Sprite2D.dodge()
			return
		"GOOD":
			$FeedbackParticle.start_good(1)

	hurt(attributes)
	var starDamageDisplay = load("res://scenes/battle/StarDamageDisplay.tscn").instantiate()
	starDamageDisplay.set_name("battleTag")
	starDamageDisplay.flipped = false
	starDamageDisplay.damage = damage
	starDamageDisplay.scale = Vector3(.1,.1,1)
	add_child(starDamageDisplay)
	health -= damage

	return health <= 0

func death_check():
	if health <= 0:
		die()
		return true
	elif health != stats.health and stats.attributes.has("transform_into"):
		start_transformation()
	return false

# this whole situation sucks.
func die():
	if not currentlyDying:
		currentlyDying = true
		change_state("dying")
		if battleTag != null:
			battleTag.queue_free()

func start_transformation():
	currentlyTransforming = true
	change_state("transforming")

func can_continue():
	return not currentlyDying and not currentlyTransforming

func transform_to_enemy():
	stats = stats.attributes["transform_into"]
	animated_sprite.set_frames(stats.frames)
	homePosition = originalHomePosition
	position = homePosition
	currentlyTransforming = false

func in_water():
	return is_in_water

func hurt(_attributes):
	$HurtParticles.play()
	$HurtParticles2.play()

func focus_camera(_camera = "3D"):
	var attemptCamera = get_node_or_null("Camera"+str(_camera))
	if(attemptCamera != null):
		$"../Camera3D".set_camera_position(attemptCamera)
	else:
		print("Failed to focus on " + str(_camera))

func unfocus_camera():
	$"../Camera3D".reset_position()

func _on_Tween_tween_all_completed():
	state.tween_completed()

func _on_Area_area_entered(area):
	state.area_body_entered(area)

func _on_SlingshotArea_area_entered(area):
	state.slingshot_area_body_entered(area)

func _on_area_3d_body_entered(body):
	state.area_body_entered(body)

func _on_slingshot_area_body_entered(body):
	state.slingshot_area_body_entered(body)
