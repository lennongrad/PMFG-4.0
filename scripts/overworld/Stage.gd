

extends Marker3D

signal water_enter(body)
signal water_exit(body)


func _on_water_body_entered(body):
	emit_signal("water_enter", body)


func _on_water_body_exited(body):
	emit_signal("water_exit", body)
