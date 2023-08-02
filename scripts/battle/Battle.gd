extends Node3D

@export var data: Resource
@export var firstStrike: String = ""
@export var battle_background: Resource
@export var debug: bool = false

var enemies = []
var finishedSpinning = false
var currentAttackingEnemy = -1
var selectedEnemy = -1
var waitingForEnemyDeath = false
var battle_over = false
var battle_won = false
var wasFirstStrike = false
var partnerAction = false
var partnerFirst = false
var experience_waiting = 0

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	$Spin.spin_backwards()
	
	var difference = .95 - data.enemies.size() * .1
	var e = 0
	for enemy in data.enemies: 
		var newEnemy = load("res://scenes/battle/EnemyBattle.tscn").instantiate()
		newEnemy.stats = enemy
		newEnemy.position.x = 3 - difference * e
		newEnemy.position.z = -.1 * e - .5
		newEnemy.is_in_water = battle_background.in_water
		enemies.append(newEnemy)
		add_child(newEnemy)
		e += 1
	enemies.reverse()

func _ready():
	randomize()
	var first_strike_attack
	match firstStrike:
		"jump":
			first_strike_attack = load("res://stats/heroattack/jump/firststrike.tres")
		"hammer":
			first_strike_attack = load("res://stats/heroattack/hammer/firststrike.tres")
	if first_strike_attack != null:
		$Mario.first_strike_active = true
		$Mario.position = enemies[0].position - Vector3(first_strike_attack.walkto_distance, 0, 0)
		$Mario.position.y = 0
	$"/root/MarioRun".start_battle()
	$Status.show_fp()
	if battle_background.in_water:
		$Mario.is_in_water = true
		$Partner.is_in_water = true
	var stage = battle_background.background.instantiate()
	add_child(stage)
	$CameraPosition.current = true

func _process(_delta):
	$Status.unhide()
	$Mario.is_selected_teammate = not partnerAction
	$Partner.is_selected_teammate = partnerAction
	if waitingForEnemyDeath:
		var continueAttacks = true
		var deadEnemies = []
		for enemy in enemies:
			if not enemy.can_continue():
				continueAttacks = false
			elif enemy.setToDie:
				enemy.queue_free()
				deadEnemies.append(enemy)
		for enemy in deadEnemies:
			enemies.erase(enemy)
		if continueAttacks:
			if wasFirstStrike or (partnerAction and not partnerFirst) or (not partnerAction and partnerFirst):
				start_mario_turn()
				wasFirstStrike = false
			else:
				next_enemy_turn(30)
			waitingForEnemyDeath = false
	if battle_over:
		if not $Mario.is_victory_posing and not $Spin.isPlaying:
			finish_battle()
	
	enemySetAttackTimer -= 1
	if enemySetAttackTimer == 0:
		enemySetToAttack.attack()
	
	pass#print(Engine.get_frames_per_second())

func enemy_select_left():
	enemies[selectedEnemy].isSelected = false
	selectedEnemy -= 1
	if selectedEnemy < 0:
		selectedEnemy += enemies.size() 
	enemies[selectedEnemy].isSelected = true

func enemy_select_right():
	enemies[selectedEnemy].isSelected = false
	selectedEnemy = (selectedEnemy + 1) % enemies.size()
	enemies[selectedEnemy].isSelected = true
	pass

func get_selected_enemy():
	return selectedEnemy

func start_enemy_select():
	selectedEnemy = 0
	enemies[selectedEnemy].isSelected = true

func end_enemy_select():
	enemies[selectedEnemy].isSelected = false
	selectedEnemy = -1

func register_damage(target, damage, effectiveness):
	return target.take_damage(damage, effectiveness)

func decrement_experience(decrease):
	if decrease:
		experience_waiting -= 1
		$"/root/MarioRun".add_experience(1)
	var n_position = Vector2(get_viewport().get_size()) / 2 + Vector2(0, -70)
	$ExperienceHolder.position += (n_position - $ExperienceHolder.position) * .1
	$ExperienceHolder.centered = true
	$ExperienceHolder.experience_count = experience_waiting

func activate_action(action, enemy):
	if action.choice == load("res://stats/heroattack/items/_battlechoice.tres"):
		$"/root/MarioRun".item_used(action)
	$"/root/MarioRun".change_fp(-action.fp_cost)
	$Mario.is_idle = false
	$Partner.is_idle = false
	for current_enemy in enemies:
		current_enemy.is_idle = false
	if enemy != null:
		enemy = enemies[enemy]
	if partnerAction:
		$Partner.attack(action, enemy)
	else:
		$Mario.attack(action, enemy)

func hero_finished(p_firstStrike):
	for enemy in enemies:
		enemy.death_check()
	waitingForEnemyDeath = true
	wasFirstStrike = p_firstStrike
	if not wasFirstStrike:
		partnerAction = not partnerAction

func start_level_up():
	$LevelUp.activate()

func finish_level_up():
	$LevelUp.deactivate()
	$Mario.finished_level_up()
	$Partner.finished_level_up()

#this is stupid
var enemySetToAttack 
var enemySetAttackTimer = 0
func next_enemy_turn(waitTime):
	currentAttackingEnemy += 1
	if currentAttackingEnemy >= enemies.size():
		currentAttackingEnemy = -1
		start_mario_turn()
		return
	enemySetToAttack = enemies[currentAttackingEnemy]
	enemySetAttackTimer = waitTime + 1

func switch_partner_first():
	if partnerAction == partnerFirst:
		partnerAction = not partnerAction
		partnerFirst = not partnerFirst
	if partnerAction:
		$BattleUI.update_choices($Partner.get_choices())
	else:
		$BattleUI.update_choices($Mario.get_choices())

func start_mario_turn():
	if enemies.size() > 0:
		for enemy in enemies:
			enemy.is_idle = true
		$Mario.is_idle = true
		$Partner.is_idle = true
		if partnerAction:
			$BattleUI.update_choices($Partner.get_choices())
		else:
			$BattleUI.update_choices($Mario.get_choices())
		$BattleUI.activate()
	else:
		$Mario.play_victory_pose()
		$Partner.play_victory_pose()
		battle_over = true
		battle_won = true

func finish_battle():
	battle_over = true
	$Status.hide_fp()
	$Spin.start_spinning()

func increment_experience(amount):
	experience_waiting += amount
	$ExperienceHolder.experience_count = experience_waiting

func _on_Spin_finishedSpinning():
	if battle_over:
		if debug:
			get_tree().quit()
		else:
			get_node("/root/Global").reset_to_main(battle_won)
	else:
		finishedSpinning = true
		$Mario.first_strike_active = false
		match firstStrike:
			"":
				start_mario_turn()
			"jump":
				$Mario.attack(load("res://stats/heroattack/jump/firststrike.tres"), enemies[0])
			"hammer":
				$Mario.attack(load("res://stats/heroattack/hammer/firststrike.tres"), enemies[0])
			"enemy":
				enemies[0].firstStrike()
