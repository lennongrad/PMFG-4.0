extends StaticBody3D

signal body_entered(body)
signal body_exited(body)

func _ready():
	pass 

func _on_Area_body_entered(body):
	emit_signal("body_entered", body)

func _on_Area_body_exited(body):
	emit_signal("body_exited", body)
