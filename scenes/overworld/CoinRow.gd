@tool

extends Node3D

@export var coin_count: int: set = set_coin_count
@export var coin_distance: Vector3: set = set_coin_distance

func set_coin_count(p_cc):
	coin_count = p_cc
	change_coins()

func set_coin_distance(p_cd):
	coin_distance = p_cd
	change_coins()

func change_coins():
	for i in range(0, get_child_count()):
		get_child(i).queue_free()
	for i in range(0, coin_count):
		var coin_object = load("res://scenes/overworld/OverworldCoin.tscn").instantiate()
		coin_object.position = i * coin_distance
		coin_object.editor = true
		add_child(coin_object)
