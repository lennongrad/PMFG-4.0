extends Node2D

func _process(_delta):
	$SubViewportContainer/SubViewport.size =  get_viewport().get_size()
