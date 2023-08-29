extends AudioStreamPlayer

@onready var original_volume = volume_db
var current_playing = false

func fade_in(time_taken=3):
	var tween = create_tween()
	volume_db = -80
	play()
	tween.tween_property(self, "volume_db", original_volume, time_taken)
	current_playing = true

func fade_out(time_taken=3):
	var tween = create_tween()
	volume_db = original_volume
	tween.tween_property(self, "volume_db", -80, time_taken)
	tween.tween_callback(tween_completed)
	current_playing = false

func tween_completed():
	stop()
