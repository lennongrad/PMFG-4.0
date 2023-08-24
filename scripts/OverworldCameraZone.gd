@tool

extends Camera3D

@export var bounds_size: Vector3: set = set_bounds_size
@export var bounds_offset: Vector3: set =set_bounds_offset
@export var use_camera = false

signal on_zone_enter(camera_zone)
signal on_zone_exit(camera_zone)

func set_bounds_offset(p_offset):
	bounds_offset = p_offset
	if not has_node("Bounds"):
		return
	$Bounds/CollisionShape3D.position = bounds_offset

func set_bounds_size(p_size):
	bounds_size = p_size
	if not has_node("Bounds"):
		return
	$Bounds/CollisionShape3D.shape = BoxShape3D.new()
	$Bounds/CollisionShape3D.shape.size = bounds_size / 2

func _ready():
	if Engine.is_editor_hint():
		return
	var mario = $"../../Player"
	connect("on_zone_enter", Callable(mario, "_on_camera_zone_enter"))
	connect("on_zone_exit", Callable(mario, "_on_camera_zone_exit"))

func _on_bounds_body_entered(body):
	if body ==  $"../../Player":
		emit_signal("on_zone_enter", self)

func _on_bounds_body_exited(body):
	if body ==  $"../../Player":
		emit_signal("on_zone_exit", self)
