extends Node3D

func play(sound, overlap = true):
	if has_node(sound):
		if not get_node(sound).playing or overlap:
			get_node(sound).play()
	else:
		print("No sound named " + sound)

func stop(sound):
	if has_node(sound):
		get_node(sound).stop()
