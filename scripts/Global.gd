extends Node
#https://docs.godotengine.org/en/3.2/getting_started/step_by_step/singletons_autoload.html

var current_scene = null
var main_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func set_main(node):
	main_scene = node

func new_main():
	call_deferred("_deferred_new_main")

func _deferred_new_main():
	get_tree().unload_current_scene()
	
	var s = ResourceLoader.load("res://scenes/overworld/Overworld.tscn")

	# Instance the new scene.
	current_scene = s.instantiate()
	current_scene.show_title = false
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

func reset_to_main(data):
	call_deferred("_deferred_reset_to_main", data)

func _deferred_reset_to_main(data):
	# Immediately free the current scene,
	# there is no risk here.
	current_scene.free()

	current_scene = main_scene
	current_scene.on_reset(data)
	current_scene.get_node("Camera3D").current = true

	# Optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)

func goto_scene(path, data, firstStrike, battle_background):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path, data, firstStrike, battle_background)


func _deferred_goto_scene(path, data, firstStrike, battle_background):
	# Load new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()
	current_scene.data = data
	current_scene.firstStrike = firstStrike
	current_scene.battle_background = battle_background
	current_scene.debug = false

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)

func get_player():
	return get_node("/root/Overworld/Player")
