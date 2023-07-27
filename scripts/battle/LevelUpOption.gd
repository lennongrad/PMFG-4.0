@tool

extends NinePatchRect

@export var stat_name: String: set = change_name
@export var icon: CompressedTexture2D: set = change_icon
@export var left_side: String: set = change_left_side
@export var right_side: String: set = change_right_side

func change_name(p_name):
	if not has_node("Name"):
		return
	stat_name = p_name
	$Name.text = stat_name

func change_icon(p_icon):
	if not has_node("Icon"):
		return
	icon = p_icon
	$Icon.texture = icon
	$Icon/Shadow.texture = icon

func change_left_side(p_left_side):
	if not has_node("Values/Left"):
		return
	left_side = p_left_side
	$Values/Left.text = String(left_side) + "→"

func change_right_side(p_right_side):
	if not has_node("Values/Right"):
		return
	right_side = p_right_side
	$Values/Right.text = String(right_side)

func _ready():
	pass 

func _process(_delta):
	$Icon.pivot_offset = $Icon.size / 2
