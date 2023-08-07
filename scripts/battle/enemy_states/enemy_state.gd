extends CharacterBody3D

class_name EnemyState

var change_state #func
var progress_attack #func
var animated_sprite
var persistent_state
var mario
var l_velocity
var partner
var camera
var floorMesh
var particles

# Writing _delta instead of delta here prevents the unused variable warning.
func _physics_process(_delta):
	persistent_state.set_velocity(persistent_state.velocity)
	persistent_state.set_up_direction(Vector3.UP)
	persistent_state.move_and_slide()
	persistent_state.slingshot_ammo.set_velocity(persistent_state.slingshotVelocity)
	persistent_state.slingshot_ammo.set_up_direction(Vector3.UP)
	persistent_state.slingshot_ammo.move_and_slide()


func interpolate_property(obj, property, finalValue, time):
	var tween = create_tween()
	tween.tween_property(obj, property, finalValue, time)
	tween.tween_callback(tween_completed)


func setup(p_change_state, p_progress_attack, p_persistent_state, p_mario, p_partner, p_floorMesh):
	self.change_state = p_change_state
	self.progress_attack = p_progress_attack
	self.persistent_state = p_persistent_state
	self.l_velocity = 0
	self.mario = p_mario
	self.partner = p_partner
	self.floorMesh = p_floorMesh
	self.particles = persistent_state.get_node("MoveParticles")

func area_body_entered(_body):
	pass
	
func slingshot_area_body_entered(_body):
	pass

func tween_completed():
	pass
