extends Control

@export var font: FontFile

@onready var actionTable = $ActionMenu/Actions
@onready var actionCursor = $ActionMenu/ActionCursor

var battleChoices = []

enum UIState {STATE_PROJECTOR, STATE_MENU, STATE_SELECT, STATE_HIDE}

var rotationDifference = -.6
var radius = 300
var rotationOrigin = Vector2(85, -75)

var currentChoices = []
var currentActions = []
var currentlyRotating = false
var currentRotation = 0
var currentSelection = 0
var selected_action = 0
var recentMovement = 0
var selectedAction
var skippedActions

var state = UIState.STATE_HIDE#UIState.STATE_PROJECTOR

func order_comparison(a, b):
	return a["choice"].order < b["choice"].order

func fp_comparison(a, b):
	return a.action.fp_cost < b.action.fp_cost

# Called when the node enters the scene tree for the first time.
func _ready():
#	var dir = DirAccess.open("res://stats/heroattack")
#	if dir:
#		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#		var file_name = dir.get_next()
#		while file_name != "":
#			if dir.current_is_dir() and file_name != "." and file_name != "..":
#				if dir.file_exists(file_name + "/_battlechoice.tres"):
#					var choice_path = "res://stats/heroattack/" + file_name
#					battleChoices.append({"choice": load(choice_path + "/_battlechoice.tres")})
#			file_name = dir.get_next()
#	else:
#		print("Could not open files")
	
	battleChoices.append({"choice": load("res://stats/heroattack/goombario/_battlechoice.tres")})
	battleChoices.append({"choice": load("res://stats/heroattack/hammer/_battlechoice.tres")})
	battleChoices.append({"choice": load("res://stats/heroattack/items/_battlechoice.tres")})
	battleChoices.append({"choice": load("res://stats/heroattack/jump/_battlechoice.tres")})
	battleChoices.append({"choice": load("res://stats/heroattack/tactics/_battlechoice.tres")})
	battleChoices.sort_custom(Callable(self, "order_comparison"))
	
	for choice in battleChoices:
		choice["active"] = true
		choice["ui"] = load("res://scenes/battle/BattleChoice.tscn").instantiate()
		$Projector.add_child(choice["ui"])
		choice["ui"].set_data(choice.choice)

func activate():
	state = UIState.STATE_PROJECTOR
	$Projector.visible = true
	$Graphic.visible = true
	$Graphic.modulate.a = 1

func update_choices(attacks):
	currentChoices = []
	for choice in battleChoices:
		choice.actions = []
		for action in attacks:
			if action.choice == choice.choice:
				choice.actions.append(action)
		choice["active"] = choice.actions.size() > 0
		if choice["choice"]["name"] == "Jump" and $"/root/MarioRun".get_badge_value("no_jump") > 0:
			choice["active"] = false
		if choice["choice"]["name"] == "Hammer" and $"/root/MarioRun".get_badge_value("no_hammer") > 0:
			choice["active"] = false
		if choice["active"]:
			currentChoices.append(choice)
	currentSelection = 1
	currentRotation = -rotationDifference

func load_actions(_action):
	state = UIState.STATE_MENU
	actionTable.clear()
	
	currentActions = []
	for action in currentChoices[currentSelection]["actions"]:
		var is_possible = true
		if action.fp_cost > $"/root/MarioRun".get_fp():
			is_possible = false
		currentActions.append({"action": action, "possible": is_possible})
	
	var is_item = currentChoices[currentSelection].choice == load("res://stats/heroattack/items/_battlechoice.tres")
	if currentActions.size() == 1 and not is_item:
		select_action(0)
		skippedActions = true
		return
	currentActions.sort_custom(Callable(self, "fp_comparison"))
	
	$ActionMenu/Title/Label.text = currentChoices[currentSelection].choice.name
	
	for i in range(0, $ActionMenu/FPLabels.get_child_count()):
		$ActionMenu/FPLabels.get_child(i).queue_free()
	
	var max_width = 0
	for action in currentActions:
		if action.action.name == "Jump":
			actionTable.add_item(action.action.name, $"/root/MarioRun".get_equipped_boots().type.icon, true)
		elif action.action.name == "Hammer":
			actionTable.add_item(action.action.name, $"/root/MarioRun".get_equipped_hammer().type.icon, true)
		else:
			if action.possible:
				actionTable.add_item(action.action.name, action.action.icon, true)
			else:
				actionTable.add_item(action.action.name, action.action.icon_gray, true)
		actionTable.set_item_tooltip_enabled(actionTable.get_item_count() - 1, false)
		if action.action.name.length() > max_width:
			max_width = action.action.name.length()
	
	var no_label = true
	for e in currentActions.size():
		if currentActions[e].action.fp_cost != 0:
			no_label = false
			var fp_count = Label.new()
			fp_count.text = str(currentActions[e].action.fp_cost) + " FP"
			fp_count.set("theme_override_fonts/font", font)
			fp_count.set("theme_override_colors/font_color", Color(1, 1, 1, 1))
			fp_count.set("theme_override_colors/font_shadow_color", Color(.6, .5, .1, 1))
			fp_count.set("theme_override_constants/shadow-offset-x", 2)
			fp_count.set("theme_override_constants/shadow-offset-y", 2)
			#fp_count.align = HORIZONTAL_ALIGNMENT_RIGHT
			fp_count.offset_left = max_width * 16 - 30
			fp_count.offset_top = y_position(e) - 12
			$ActionMenu/FPLabels.add_child(fp_count)
		if not currentActions[e].possible:
			actionTable.select(e, true)
		e += 1
	
	var scale_x = .0175 * max_width + .075
	if not no_label:
		scale_x += .075
	#get_viewport().get_size() * Vector2(.0008, .0013)
	$ActionMenu/Background.scale.x = scale_x
	$ActionMenu/Background.texture_scale.x = $ActionMenu/Background.scale.x * .5
	$ActionMenu/Background.scale.y = currentActions.size() * .049 + .045
	$ActionMenu/Background.texture_scale.y = $ActionMenu/Background.scale.y * .5166
	selected_action = 0
	skippedActions = false

func rotate_left():
	if not currentlyRotating and currentSelection > 0:
		currentSelection -= 1
		currentlyRotating = true

func rotate_right():
	if not currentlyRotating and currentSelection < currentChoices.size() - 1:
		currentSelection += 1
		currentlyRotating = true

func select_up():
	var nextSelection = selected_action - 1
	if nextSelection < 0:
		nextSelection = actionTable.get_item_count() + nextSelection
	selected_action = nextSelection

func select_down():
	var nextSelection = (selected_action + 1) % actionTable.get_item_count()
	selected_action = nextSelection

func select_action(action):
	selectedAction = currentActions[action]
	if selectedAction.possible:
		selectedAction = selectedAction.action
		if selectedAction.skipEnemySelection:
			$"..".activate_action(selectedAction, null)
			state = UIState.STATE_HIDE
		else:
			state = UIState.STATE_SELECT
			$"..".start_enemy_select()

func y_position(index):
	return index * 32 + 12

func select_enemy(enemy):
	$"..".end_enemy_select()
	$"..".activate_action(selectedAction, enemy)
	state = UIState.STATE_HIDE

func _process(delta):
	var f_size = Vector2(get_viewport().get_size())
	$Projector.scale = f_size * Vector2(.0008, .0013) + Vector2(.2, .1)
	$Projector.position.x = f_size.x * .04
	$Graphic.scale = Vector2(1,1) * f_size.x / 1500
	$ActionMenu.scale = f_size * Vector2(.0008, .0013) + Vector2(.2, .1)
	$ActionMenu/Background.texture_offset += Vector2(1, 1) * .5
	$CanSwitch.visible = $"..".can_switch_partner()
	
	recentMovement += 1
	match state:
		UIState.STATE_PROJECTOR:
			$Projector.modulate.a += (1 - $Projector.modulate.a) * .2
			$ActionMenu.modulate.a -= $ActionMenu.modulate.a * .2
			var rotationGoal = (currentSelection) * -45 + 22.5
			$Graphic.rotation += (rotationGoal - $Graphic.rotation) * .25
			if recentMovement > 20:
				if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_down"):
					rotate_right()
					recentMovement = 0
				if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_up"):
					rotate_left()
					recentMovement = 0
				if Input.is_action_just_pressed("spin"):
					if $"..".can_switch_partner():
						$"..".switch_partner_first()
						recentMovement = -20
				if Input.is_action_just_pressed("jump"):
					load_actions(currentChoices[currentSelection])
					recentMovement = -10
			var e = 0
			for choice in battleChoices:
				choice["ui"].visible = false
			for choice in currentChoices:
				var theta = currentRotation + rotationDifference * e + .41  + .1
				choice["ui"].visible = true
				choice["ui"].position = rotationOrigin + radius * Vector2(cos(theta), -sin(theta))
				choice["ui"].selected = currentSelection == e
				if currentSelection == e and currentlyRotating:
					if currentRotation + rotationDifference * e < -.05:
						currentRotation += delta * 2
					elif currentRotation + rotationDifference * e > .05:
						currentRotation -= delta * 2
					else:
						currentRotation = -rotationDifference * e
						currentlyRotating = false
				e += 1
			if currentlyRotating:
				$Projector/ProjectorLight.modulate.a = .1
			else:
				$Projector/ProjectorLight.modulate.a = .73
		UIState.STATE_MENU:
			$ActionMenu.visible = true
			if recentMovement > 0:
				if Input.is_action_just_pressed("ui_up"):
					select_up()
					recentMovement = 0
				if Input.is_action_just_pressed("ui_down"):
					select_down()
					recentMovement = 0
				if Input.is_action_just_pressed("back"):
					state = UIState.STATE_PROJECTOR
					recentMovement = 0
				if Input.is_action_just_pressed("jump"):
					select_action(selected_action)
					recentMovement = -10
			actionCursor.position.y += (y_position(selected_action) - actionCursor.position.y) * .25
			$Projector.modulate.a -= $Projector.modulate.a * .2
			$ActionMenu.modulate.a += (1 - $ActionMenu.modulate.a) * .2
		UIState.STATE_SELECT:
			if Input.is_action_just_pressed("ui_left"):
				$"..".enemy_select_left()
				recentMovement = 0
			if Input.is_action_just_pressed("ui_right"):
				$"..".enemy_select_right()
				recentMovement = 0
			if Input.is_action_just_pressed("back"):
				if skippedActions:
					state = UIState.STATE_PROJECTOR
				else:
					state = UIState.STATE_MENU
				recentMovement = 0
				$"..".end_enemy_select()
			if Input.is_action_just_pressed("jump"):
				select_enemy($"..".get_selected_enemy())
			$Projector.modulate.a -= $Projector.modulate.a * .2
			$ActionMenu.modulate.a -= $ActionMenu.modulate.a * .2
		UIState.STATE_HIDE:
			$CanSwitch.visible = false
			$Projector.modulate.a -= $Projector.modulate.a * .2
			$Graphic.modulate.a -= $Graphic.modulate.a * .2
			$ActionMenu.modulate.a -= $ActionMenu.modulate.a * .2
