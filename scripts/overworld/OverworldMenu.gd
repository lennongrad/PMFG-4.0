extends Control

@onready var tabs = [
	{"name": "Mario", "button_modulate": Color("bf4a38"), "panel_modulate": Color("d32c2c"), 
		"border_modulate": Color("b55c56")},
	{"name": "Party", "button_modulate": Color("ba378c"), "panel_modulate": Color("b62cd3"), 
		"border_modulate": Color("b556af")}
]

var pip_icons_filled = [
	preload("res://sprites/badgepips//0f.png"),
	preload("res://sprites/badgepips/1f.png"),
	preload("res://sprites/badgepips/2f.png"),
	preload("res://sprites/badgepips/3f.png"),
	preload("res://sprites/badgepips/4f.png"),
	preload("res://sprites/badgepips/5f.png"),
	preload("res://sprites/badgepips/6f.png")
]

var pip_icons_empty = [
	preload("res://sprites/badgepips/0e.png"),
	preload("res://sprites/badgepips/1e.png"),
	preload("res://sprites/badgepips/2e.png"),
	preload("res://sprites/badgepips/3e.png"),
	preload("res://sprites/badgepips/4e.png"),
	preload("res://sprites/badgepips/5e.png"),
	preload("res://sprites/badgepips/6e.png")
]

enum MenuState { ITEMS, BADGE, BOOTS, HAMMER, NONE }
var menu_state = MenuState.NONE

var selected_badge = 0
var selected_sub_badge = 0
var selecting_sub = false
var global_timer = 0
var hurt_timer = 0

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#start_menu();
	position.y = 1100

func start_menu():
	menu_state = MenuState.NONE
	chosen_badges()
	$Panel/Buttons/Mario.grab_focus()
	active = true
	global_timer = 0

func end_menu():
	active = false
	$"..".close_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_timer += 1
	
	if not active:
		position.y += (1100 - position.y) * .05
		$Background.modulate.a += -$Background.modulate.a * .1
		$Cursor.modulate.a = 0
		return
	position.y += -position.y * .1
	$Background.modulate.a += (1 - $Background.modulate.a) * .1
	$Cursor.modulate.a += (1 - $Cursor.modulate.a) * .05
	
	if Input.is_action_just_pressed("menu") and global_timer > 10:
		end_menu()
	
	for e in range(0, tabs.size()):
		if $Panel/TabContainer.current_tab != e:
			get_node("Panel/Buttons/" + tabs[e].name).modulate = Color(.4, .4, .4)
		else:
			get_node("Panel/Buttons/" + tabs[e].name).modulate = Color(1, 1, 1)
			$Panel/Checkers.modulate = tabs[e].panel_modulate
			$Panel/TopBorder.modulate = tabs[e].border_modulate
			$Panel/BottomBorder.modulate = tabs[e].border_modulate
	
	$Panel/TabContainer/Mario/Header/Stats/FP/Label2.text = str(get_node("/root/MarioRun").get_max_fp())
	$Panel/TabContainer/Mario/Header/Stats/BP/Label2.text = str(get_node("/root/MarioRun").get_max_bp())
	
	if(get_node("/root/MarioRun").get_items().size() > 0):
		$Panel/TabContainer/Mario/Equipment/Bag/Sprite2D.texture = get_node("/root/MarioRun").get_items()[0].icon
	else:
		$Panel/TabContainer/Mario/Equipment/Bag/Sprite2D.texture = load("res://sprites/items/fireflower.png")
	
	var first_badge = get_node("/root/MarioRun").get_equipped_badges()
	if first_badge.is_empty():
		$Panel/TabContainer/Mario/Equipment/Badges/Sprite2D.texture = load("res://sprites/other/bp.png")
	else:
		$Panel/TabContainer/Mario/Equipment/Badges/Sprite2D.texture = first_badge.keys()[0].icon
	
	match menu_state:
		MenuState.NONE:
			var mario_scale = Vector2(1, 1)
			mario_scale *= $Panel/TabContainer/Mario/Equipment.size.y / 58
			$Panel/TabContainer/Mario/Equipment/Control/Mario.scale = mario_scale
			
			var position_offset
			for child in range(0, $Panel/Buttons.get_children().size()):
				if $Panel/Buttons.get_children()[child].has_focus():
					$Panel/TabContainer.current_tab = child
					position_offset = Vector2(60, -5)
			
			for child in $Panel/TabContainer/Mario/Equipment.get_children():
				if child.has_focus():
					position_offset = Vector2(60, -5)
			
			if ($Panel/TabContainer/Mario/Header/Pieces.has_focus()):
				position_offset = Vector2(30, -15)
			
			if ($Panel/TabContainer/Mario/Header/Bar/Level.has_focus() or 
				$Panel/TabContainer/Mario/Header/Bar/Label.has_focus()):
				position_offset = Vector2(60, -5)
			
			for child in $Panel/TabContainer/Mario/Header/Stats.get_children():
				if child.has_focus():
					position_offset = Vector2(60, -5)
			
			$Panel/TabContainer/Mario/ItemHeader/Background.visible = false
			$Panel/TabContainer/Mario/ItemHeader/BadgePips.clear()
			
			if (not $Panel/TabContainer/Mario/Equipment/Badges.has_focus()
				and not $Panel/TabContainer/Mario/Equipment/Bag.has_focus()
				and not $Panel/TabContainer/Mario/Equipment/Boots.has_focus()
				and not $Panel/TabContainer/Mario/Equipment/Hammer.has_focus()):
					$Panel/TabContainer/Mario/ItemArea/Tree.clear()
					$Panel/TabContainer/Mario/ItemHeader/Label.text = ""
			
			$Panel/TabContainer/Mario/Equipment/Control/Mario/Hammer.visible = false
			if $Panel/TabContainer/Mario/Equipment/Badges.has_focus():
				show_badges()
				$Panel/TabContainer/Mario/ItemHeader/Background.visible = true
				$Panel/TabContainer/Mario/Equipment/Control/Mario.play("Present")
				$Panel/TabContainer/Mario/Equipment/Control/Mario.position = Vector2(9, -5)
			elif $Panel/TabContainer/Mario/Equipment/Bag.has_focus():
				show_items()
				$Panel/TabContainer/Mario/Equipment/Control/Mario.play("Eat")
				$Panel/TabContainer/Mario/Equipment/Control/Mario.position = Vector2(-3, -5)
			elif $Panel/TabContainer/Mario/Equipment/Boots.has_focus():
				show_boots()
				$Panel/TabContainer/Mario/Equipment/Control/Mario.play("Jumpsquat")
				$Panel/TabContainer/Mario/Equipment/Control/Mario.position = Vector2(-1, -5)
			elif $Panel/TabContainer/Mario/Equipment/Hammer.has_focus():
				show_hammers()
				$Panel/TabContainer/Mario/Equipment/Control/Mario.play("HoldHammer1")
				$Panel/TabContainer/Mario/Equipment/Control/Mario.position = Vector2(-12, -5)
				$Panel/TabContainer/Mario/Equipment/Control/Mario/Hammer.visible = true
			elif $Panel/TabContainer/Mario/Header/Bar/Label.has_focus():
				$Panel/TabContainer/Mario/Equipment/Control/Mario.play("Victory")
				$Panel/TabContainer/Mario/Equipment/Control/Mario.position = Vector2(9, -5)
			elif $Panel/TabContainer/Mario/Header/Bar/Level.has_focus():
				$Panel/TabContainer/Mario/Equipment/Control/Mario.play("Skip")
				$Panel/TabContainer/Mario/Equipment/Control/Mario.position = Vector2(-1, -5)
			else:
				$Panel/TabContainer/Mario/Equipment/Control/Mario.play("Think")
				$Panel/TabContainer/Mario/Equipment/Control/Mario.position = Vector2(12, -5)
			$Panel/TabContainer/Mario/ItemArea/Tree.modulate.a = .4
			
			$Cursor.play("down")
			if get_viewport().gui_get_focus_owner().tooltip_text != "":
				$Panel/Text.on_set_text(get_viewport().gui_get_focus_owner().tooltip_text)
			$Cursor.position += (get_viewport().gui_get_focus_owner().global_position + position_offset - $Cursor.position) * .25
			if $Cursor.position.x > $Panel/TabContainer/Mario/Header/Stats/BP.get_global_transform().origin.x + 61:
				$Cursor.flip_h = true
			else:
				$Cursor.flip_h = false
			
			if Input.is_action_just_pressed("back") and global_timer > 10:
				end_menu()
		MenuState.ITEMS:
			$Cursor.play("right")
			$Cursor.flip_h = false
			var tree = $Panel/TabContainer/Mario/ItemArea/Tree
			var item = tree.get_root().get_children()[selected_badge]
			tree.scroll_to_item(item)
			var new_position = (tree.get_item_area_rect(item).position - tree.get_scroll()
			 + tree.get_global_transform().origin + Vector2(4 + cos(float(global_timer) / 4) * 2, 16))
			$Cursor.position += (new_position - $Cursor.position) * .25
			$Panel/Text.on_set_text(get_node("/root/MarioRun").get_items()[selected_badge].description)
			
			if Input.is_action_just_pressed("back"):
				$Panel/TabContainer/Mario/Equipment/Bag.grab_focus()
				tree.clear()
				menu_state = MenuState.NONE
				chosen_badges()
			if Input.is_action_just_pressed("ui_up"):
				selected_badge -= 1
				if selected_badge < 0:
					selected_badge = get_node("/root/MarioRun").get_items().size() - 1
			if Input.is_action_just_pressed("ui_down"):
				selected_badge = (selected_badge + 1) % get_node("/root/MarioRun").get_items().size()
			if Input.is_action_just_pressed("jump"):
				pass
		MenuState.BOOTS:
			$Cursor.play("right")
			$Cursor.flip_h = false
			var tree = $Panel/TabContainer/Mario/ItemArea/Tree
			var item = tree.get_root().get_children()[selected_badge]
			if selecting_sub:
				item = item.get_children()[selected_sub_badge]
			var new_position = (tree.get_item_area_rect(item).position
			 + tree.get_global_transform().origin + Vector2(4 + cos(float(global_timer) / 4) * 2, 16))
			if selecting_sub:
				new_position.x += 5
				$Panel/Text.on_set_text(get_node("/root/MarioRun").get_boots_list()[selected_badge].badges[selected_sub_badge].description)
			else:
				$Panel/Text.on_set_text(get_node("/root/MarioRun").get_boots_list()[selected_badge].type.description)
				pass
			$Cursor.position += (new_position - $Cursor.position) * .25
			
			$Panel/TabContainer/Mario/Equipment/Boots/Sprite2D.texture = get_node("/root/MarioRun").get_equipped_boots().type.icon
			
			if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("ui_left"):
				if selecting_sub:
					selecting_sub = false
				else:
					$Panel/TabContainer/Mario/Equipment/Boots.grab_focus()
					tree.clear()
					menu_state = MenuState.NONE
					chosen_badges()
			if Input.is_action_just_pressed("ui_right"):
				selecting_sub = true
				selected_sub_badge = 0
			if Input.is_action_just_pressed("ui_up"):
				if selecting_sub:
					selected_sub_badge -= 1
					if selected_sub_badge < 0:
						selected_sub_badge = get_node("/root/MarioRun").get_boots_list()[selected_badge].badges.size() - 1
				else:
					selected_badge -= 1
					if selected_badge < 0:
						selected_badge = get_node("/root/MarioRun").get_boots_list().size() - 1
			if Input.is_action_just_pressed("ui_down"):
				if selecting_sub:
					selected_sub_badge = (selected_sub_badge + 1) % get_node("/root/MarioRun").get_boots_list()[selected_badge].badges.size() 
				else:
					selected_badge = (selected_badge + 1) % get_node("/root/MarioRun").get_boots_list().size()
			if Input.is_action_just_pressed("jump"):
				get_node("/root/MarioRun").equip_boots(selected_badge)
				show_boots()
		MenuState.HAMMER:
			$Cursor.play("right")
			$Cursor.flip_h = false
			var tree = $Panel/TabContainer/Mario/ItemArea/Tree
			var item = tree.get_root().get_children()[selected_badge]
			if selecting_sub:
				item = item.get_children()[selected_sub_badge]
			var new_position = (tree.get_item_area_rect(item).position
			 + tree.get_global_transform().origin + Vector2(4 + cos(float(global_timer) / 4) * 2, 16))
			if selecting_sub:
				new_position.x += 5
				$Panel/Text.on_set_text(get_node("/root/MarioRun").get_hammer_list()[selected_badge].badges[selected_sub_badge].description)
			else:
				$Panel/Text.on_set_text(get_node("/root/MarioRun").get_hammer_list()[selected_badge].type.description)
				pass
			$Cursor.position += (new_position - $Cursor.position) * .25
			
			$Panel/TabContainer/Mario/Equipment/Hammer/Sprite2D.texture = get_node("/root/MarioRun").get_equipped_hammer().type.icon
			
			if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("ui_left"):
				if selecting_sub:
					selecting_sub = false
				else:
					$Panel/TabContainer/Mario/Equipment/Hammer.grab_focus()
					tree.clear()
					menu_state = MenuState.NONE
					chosen_badges()
			if Input.is_action_just_pressed("ui_right"):
				if get_node("/root/MarioRun").get_hammer_list()[selected_badge].badges.size() > 0:
					selecting_sub = true
					selected_sub_badge = 0
			if Input.is_action_just_pressed("ui_up"):
				if selecting_sub:
					selected_sub_badge -= 1
					if selected_sub_badge < 0:
						selected_sub_badge = get_node("/root/MarioRun").get_hammer_list()[selected_badge].badges.size() - 1
				else:
					selected_badge -= 1
					if selected_badge < 0:
						selected_badge = get_node("/root/MarioRun").get_hammer_list().size() - 1
			if Input.is_action_just_pressed("ui_down"):
				if selecting_sub:
					selected_sub_badge = (selected_sub_badge + 1) % get_node("/root/MarioRun").get_hammer_list()[selected_badge].badges.size() 
				else:
					selected_badge = (selected_badge + 1) % get_node("/root/MarioRun").get_hammer_list().size()
			if Input.is_action_just_pressed("jump"):
				get_node("/root/MarioRun").equip_hammer(selected_badge)
				#$"..".update_menu()
				$Panel/TabContainer/Mario/Equipment/Control/Mario/Hammer.frames = (
					get_node("/root/MarioRun").get_equipped_hammer().type.frames_sprites)
				show_hammers()
		MenuState.BADGE:
			$Cursor.play("right")
			var tree = $Panel/TabContainer/Mario/ItemArea/Tree
			var item = tree.get_root().get_children()[selected_badge]
			tree.scroll_to_item(item)
			var new_position = (tree.get_item_area_rect(item).position
			 + tree.get_global_transform().origin - tree.get_scroll()
			 + Vector2(4 + cos(float(global_timer) / 4) * 2, 16))
			$Cursor.position += (new_position - $Cursor.position) * .25
			if get_node("/root/MarioRun").get_badges().size() > selected_badge:
				$Panel/Text.on_set_text(get_node("/root/MarioRun").get_badges()[selected_badge].badge.description)
			
			if hurt_timer > 0:
				hurt_timer -= 1
				$Panel/TabContainer/Mario/Equipment/Control/Mario.play("Hurt")
				$Panel/TabContainer/Mario/Equipment/Control/Mario.position = Vector2(5, -5)
			else:
				$Panel/TabContainer/Mario/Equipment/Control/Mario.play("Present")
				$Panel/TabContainer/Mario/Equipment/Control/Mario.position = Vector2(9, -5)
			
			if Input.is_action_just_pressed("back"):
				$Panel/TabContainer/Mario/Equipment/Badges.grab_focus()
				tree.clear()
				menu_state = MenuState.NONE
				chosen_badges()
			if Input.is_action_just_pressed("ui_up"):
				selected_badge -= 1
				if selected_badge < 0:
					selected_badge = get_node("/root/MarioRun").get_badges().size() - 1
			if Input.is_action_just_pressed("ui_down"):
				selected_badge = (selected_badge + 1) % get_node("/root/MarioRun").get_badges().size()
			if Input.is_action_just_pressed("jump"):
				if not get_node("/root/MarioRun").toggle_badge(selected_badge):
					hurt_timer = 30
				update_badges()

func enter_item_state():
	if get_node("/root/MarioRun").get_items().size() == 0:
		return
	menu_state = MenuState.ITEMS

	selected_badge = 0
	show_items()
	#$Panel/TabContainer/Mario/ItemArea/Tree.get_root().get_children()[0].grab_focus()
	$Panel/TabContainer/Mario/ItemArea/Tree.modulate.a = 1

func show_items():
	var tree = $Panel/TabContainer/Mario/ItemArea/Tree
	tree.clear()
	tree.set_column_expand(0, false)
	tree.set_column_custom_minimum_width(0, 50)
	tree.set_column_expand(1, true)
	tree.set_column_expand(2, false)
	tree.set_column_custom_minimum_width(2, 55)
	
	$Panel/TabContainer/Mario/ItemHeader/Label.text = ("Items: " + 
		str(get_node("/root/MarioRun").get_items().size()))
	
	var root = tree.create_item()
	var items = get_node("/root/MarioRun").get_items()
	for item in items:
		var tree_item = tree.create_item(root)
		tree_item.set_icon(0, item.icon)
		tree_item.set_expand_right(0, false)
		tree_item.set_text(1, item.name)
		tree_item.set_expand_right(1, true)

func enter_boots_state():
	menu_state = MenuState.BOOTS

	selected_badge = 0
	show_boots()
#	$Panel/TabContainer/Mario/ItemArea/Tree.get_children()[0].grab_focus()
	$Panel/TabContainer/Mario/ItemArea/Tree.modulate.a = 1

func show_boots():
	var tree = $Panel/TabContainer/Mario/ItemArea/Tree
	tree.clear()
	tree.set_column_expand(0, false)
	tree.set_column_custom_minimum_width(0, 60)
	tree.set_column_expand(1, true)
	tree.set_column_expand(2, false)
	tree.set_column_custom_minimum_width(2, 55)
	
	$Panel/TabContainer/Mario/ItemHeader/Label.text = ("Boots: " + 
		str(get_node("/root/MarioRun").get_boots_list().size()))
	
	var root = tree.create_item()
	var items = get_node("/root/MarioRun").get_boots_list()
	for item in items:
		var tree_item = tree.create_item(root)
		tree_item.set_icon(0, item.type.icon)
		tree_item.set_expand_right(0, false)
		tree_item.set_text(1, item.name)
		tree_item.set_expand_right(1, true)
		if item == get_node("/root/MarioRun").get_equipped_boots():
			tree_item.select(0)
			tree_item.select(1)
		
		for badge in item.badges:
			var tree_sub_item = tree.create_item(tree_item)
			tree_sub_item.set_icon(0, badge.icon)
			tree_sub_item.set_expand_right(0, false)
			tree_sub_item.set_text(1, badge.name)
			tree_sub_item.set_expand_right(1, true)
			if item == get_node("/root/MarioRun").get_equipped_boots():
				tree_sub_item.select(0)
				tree_sub_item.select(1)

func enter_hammer_state():
	menu_state = MenuState.HAMMER

	selected_badge = 0
	show_hammers()
	
	print($Panel/TabContainer/Mario/ItemArea/Tree.get_children())
#	$Panel/TabContainer/Mario/ItemArea/Tree.get_children()[0].grab_focus()
	$Panel/TabContainer/Mario/ItemArea/Tree.modulate.a = 1

func show_hammers():
	var tree = $Panel/TabContainer/Mario/ItemArea/Tree
	tree.clear()
	tree.set_column_expand(0, false)
	tree.set_column_custom_minimum_width(0, 60)
	tree.set_column_expand(1, true)
	tree.set_column_expand(2, false)
	tree.set_column_custom_minimum_width(2, 55)
	
	$Panel/TabContainer/Mario/ItemHeader/Label.text = ("Hammers: " + 
		str(get_node("/root/MarioRun").get_hammer_list().size()))
	
	var root = tree.create_item()
	var items = get_node("/root/MarioRun").get_hammer_list()
	for item in items:
		var tree_item = tree.create_item(root)
		tree_item.set_icon(0, item.type.icon)
		tree_item.set_expand_right(0, false)
		tree_item.set_text(1, item.name)
		tree_item.set_expand_right(1, true)
		if item == get_node("/root/MarioRun").get_equipped_hammer():
			tree_item.select(0)
			tree_item.select(1)
		
		for badge in item.badges:
			var tree_sub_item = tree.create_item(tree_item)
			tree_sub_item.set_icon(0, badge.icon)
			tree_sub_item.set_expand_right(0, false)
			tree_sub_item.on_set_text(1, badge.name)
			tree_sub_item.set_expand_right(1, true)
			if item == get_node("/root/MarioRun").get_equipped_hammer():
				tree_sub_item.select(0)
				tree_sub_item.select(1)

func enter_badge_state():
	if get_node("/root/MarioRun").get_badges().size() == 0:
		return
	menu_state = MenuState.BADGE

	selected_badge = 0
	show_badges()
#	$Panel/TabContainer/Mario/ItemArea/Tree.get_children()[0].grab_focus()
	$Panel/TabContainer/Mario/ItemArea/Tree.modulate.a = 1

func chosen_badges():
	get_node("/root/MarioRun").sort_badges()

func show_badges():
	var tree = $Panel/TabContainer/Mario/ItemArea/Tree
	tree.clear()
	tree.set_column_expand(0, false)
	tree.set_column_custom_minimum_width(0, 50)
	tree.set_column_expand(1, true)
	tree.set_column_expand(2, false)
	tree.set_column_custom_minimum_width(2, 55)
	
	var root = tree.create_item()
	var badges = get_node("/root/MarioRun").get_badges()
	for badge in badges:
		var item = tree.create_item(root)
		item.set_icon(0, badge["badge"].icon)
		item.set_expand_right(0, false)
		item.set_text(1, badge["badge"].name)
		item.set_expand_right(1, true)
	update_badges()

func update_badges():
	var max_bp =  get_node("/root/MarioRun").get_max_bp()
	
	$Panel/TabContainer/Mario/ItemHeader/Label.text = (
		"BP Available: " + str(max_bp - get_node("/root/MarioRun").get_bp_used()))
	$Panel/TabContainer/Mario/ItemHeader/BadgePips.clear()
	for badge_pip in max_bp:
		if badge_pip < get_node("/root/MarioRun").get_bp_used():
			$Panel/TabContainer/Mario/ItemHeader/BadgePips.add_icon_item(load("res://sprites/badgepips/1f.png"), false)
		else:
			$Panel/TabContainer/Mario/ItemHeader/BadgePips.add_icon_item(load("res://sprites/badgepips/1e.png"), false)
	
	var tree = $Panel/TabContainer/Mario/ItemArea/Tree
	var badges = get_node("/root/MarioRun").get_badges()
	var items = tree.get_root().get_children()
	var index = 0
	for badge in badges:
		var item = items[index]
		index+=1;
		if badge.active:
			item.set_icon(2, pip_icons_filled[badge["badge"].bp])
			item.select(0)
			item.select(1)
			item.select(2)
		else:
			item.set_icon(2, pip_icons_empty[badge["badge"].bp])
			item.deselect(0)
			item.deselect(1)
			item.deselect(2)
		item.set_expand_right(2, false)

func _on_Badges_pressed():
	enter_badge_state()

func _on_Bag_pressed():
	enter_item_state()

func _on_Boots_pressed():
	enter_boots_state()

func _on_Hammer_pressed():
	enter_hammer_state()
