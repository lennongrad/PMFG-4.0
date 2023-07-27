extends ItemList


var badge_number = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	for badge in badge_number:
		add_icon_item(load("res://UI/badgeempty.png"), false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
