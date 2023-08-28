extends Control

var test_random_items = []
var active = false
var global_timer = 1

var keeper

var selected_item = 0

func get_items():
	if keeper != null:
		return keeper.items
	return []

func get_price(item):
	return item.name.length()

func _ready():
	position.y = 1100

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
	
	if (Input.is_action_just_pressed("ui_up") 
		or Input.is_action_just_pressed("ui_down") 
		or Input.is_action_just_pressed("ui_left") 
		or Input.is_action_just_pressed("ui_right")):
		$SFX.play("Menu/Move")
	if Input.is_action_just_pressed("jump"):
		$SFX.play("Menu/Option")
	
	menu_movement()
	if ((Input.is_action_just_pressed("menu") or Input.is_action_just_pressed("back")) 
		and global_timer > 10):
		end_menu()
	
func menu_movement():
	$Cursor.play("right")
	$Cursor.flip_h = false
	var tree = $Panel/ItemArea/Tree
	var item = tree.get_root().get_children()[selected_item]
	tree.scroll_to_item(item)
	var new_position = (tree.get_item_area_rect(item).position - tree.get_scroll()
	 + tree.get_global_transform().origin + Vector2(4 + cos(float(global_timer) / 4) * 2, 16))
	$Cursor.position += (new_position - $Cursor.position) * .25
	
	var current_item = get_items()[selected_item]
	$Panel/Text.on_set_text(current_item.description)
	
	var was_used = false
	if Input.is_action_just_pressed("jump"):
		if get_price(current_item) <= $"/root/MarioRun".get_coins():
			$"/root/MarioRun".add_item(current_item)
			$"/root/MarioRun".change_coins(-get_price(current_item))
			get_items().remove_at(get_items().find(current_item))
			was_used = true
	if Input.is_action_just_pressed("back") or was_used:
		show_items()
	if Input.is_action_just_pressed("ui_up"):
		selected_item -= 1
		if selected_item < 0:
			selected_item = get_items().size() - 1
	if Input.is_action_just_pressed("ui_down"):
		selected_item = (selected_item + 1) % get_items().size()

func start_menu(_keeper):
	show_items()
	global_timer = 0
	active = true
	keeper = _keeper
	$SFX.play("Menu/In")
	show_items()

func end_menu():
	active = false
	$SFX.play("Menu/Out")
	$"..".close_menu()

func show_items():
	var tree = $Panel/ItemArea/Tree
	tree.clear()
	tree.set_column_expand(0, false)
	tree.set_column_custom_minimum_width(0, 50)
	tree.set_column_expand(1, true)
	tree.set_column_expand(2, false)
	tree.set_column_custom_minimum_width(2, 55)
	
	var root = tree.create_item()
	var items = get_items()
	for item in items:
		var tree_item = tree.create_item(root)
		tree_item.set_icon(0, item.icon)
		tree_item.set_expand_right(0, false)
		tree_item.set_text(1, item.name)
		tree_item.set_text(2, "(" + str(get_price(item)) + ")")
		tree_item.set_expand_right(1, true)
