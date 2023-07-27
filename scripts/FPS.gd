extends Control

func _ready():
	print("FPS ready")

func _process(_delta):
	$Label.text = "fps: " + str(Engine.get_frames_per_second())
