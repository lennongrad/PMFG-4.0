extends CharacterBody3D

@export var encounter_data: Resource 
@export var battle_background: Resource
@export var velocity_x = 1.5
@export var face_right = false

var paused = false
var dead = false
var death_timer = 0
var blink_timer = 0


var player

signal encounter_triggered(encounteredEnemy, first_strike)

func play_hurt():
	$HurtParticles.play()
	$Sprite2D.play("Hurt")

func _physics_process(_delta):
	if paused:
		return
	
	$Sprite2D.set_flip_h(face_right)
	if blink_timer > 0:
		blink_timer -= 1
		$Sprite2D.visible = (blink_timer % 16) > 4
	else:
		$Sprite2D.visible = true
	
	if dead:
		$Sprite2D.play("Hurt")
		death_timer += 2
		if death_timer < 100:
			$Sprite2D.rotation_degrees.y = -death_timer * 4.5
		elif death_timer < 190:
			$Sprite2D.rotation_degrees.y = 0
			$Sprite2D.fallTimer = death_timer - 80
		else:
			queue_free()
	else:
		velocity = Vector3(-velocity_x,0,0)
		if face_right:
			velocity.x *= -1
		move_and_slide()

func die():
	dead = true
	$CollisionShape3D.disabled = true

func run_away():
	blink_timer = 300

func _on_pause():
	paused = true

func _on_unpause():
	paused = false

func set_encounter(p_encounter_data):
	encounter_data = p_encounter_data
	$Sprite2D.set_frames(encounter_data.enemies[0].frames)

func _on_normal_encounter_area_entered(area):
	if paused or player == null or dead or blink_timer > 0:
		return
	match area:
		player.behind_area:
			emit_signal("encounter_triggered", self, "enemy")
		player.normal_area:
			emit_signal("encounter_triggered", self, "")
		player.hammer_area:
			emit_signal("encounter_triggered", self, "hammer")
		player.jump_area:
			emit_signal("encounter_triggered", self, "jump")
