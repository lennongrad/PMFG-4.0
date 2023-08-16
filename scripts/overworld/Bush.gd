extends Area3D

var wiggle_timer = 0
var has_been_shook = false

func get_player():
	return get_node("/root/Global").get_player()

func update_wiggle(wiggle):
	if not has_node("BushShake"):
		return
	
	$BushShake.visible = wiggle
	$BushStill.visible = not wiggle

func _process(delta):
	$Exclamation.rotate(Vector3.UP, delta * 4)
	if Input.is_action_just_pressed("jump") and $Exclamation.visible:
		wiggle_timer = 31
		if not has_been_shook:
			has_been_shook = true
			var coin_count = 3
			for _i in range(0, coin_count):
				var coin = load("res://scenes/overworld/OverworldCoin.tscn").instantiate()
				$"../../..".add_child(coin)
				coin.position = position + Vector3(0, .5, -.2)
	
	wiggle_timer -= 1
	update_wiggle(wiggle_timer > 0)

func _on_body_entered(body):
	if get_player() == body:
		$Exclamation.rotation_degrees.y = 0
		$Exclamation.visible = true
		get_player().by_bush = true

func _on_body_exited(body):
	if get_player() == body:
		$Exclamation.visible = false
		get_player().by_bush = false
