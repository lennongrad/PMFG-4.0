@tool

extends Node3D

@export var size: Vector3: set = updateSize
@export_range(0, 1, 0.05) var border_radius: float: set = updateRadius

func updateSize(newSize):
	size = newSize
	updateMesh()

func updateRadius(newRadius):
	border_radius = newRadius
	updateMesh()

func updateMesh():
	if not has_node("MeshInstance3D"):
		return
	
	# constants to make things easier
	var half_x = size.x / 2
	var half_y = size.z / 2
	var half_x_close = half_x * (1 - border_radius)
	var half_y_close = half_y * (1 - border_radius)
	var uv_near = border_radius * .5
	var uv_far = 1 - (border_radius * .5)
	var triangle_x = half_x - half_x_close
	var triangle_y = half_y - half_y_close
	var angle = atan(size.z / size.x) / PI * 180
	
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	mesh_data[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(
		[
			Vector3(-half_x,0,-half_y),
			Vector3(-half_x_close,0,-half_y),
			Vector3(half_x_close,0,-half_y),
			Vector3(half_x,0,-half_y),
			Vector3(-half_x,0,-half_y_close),
			Vector3(-half_x_close,0,-half_y_close),
			Vector3(half_x_close,0,-half_y_close),
			Vector3(half_x,0,-half_y_close),
			Vector3(-half_x,0,half_y_close),
			Vector3(-half_x_close,0,half_y_close),
			Vector3(half_x_close,0,half_y_close),
			Vector3(half_x,0,half_y_close),
			Vector3(-half_x,0,half_y),
			Vector3(-half_x_close,0,half_y),
			Vector3(half_x_close,0,half_y),
			Vector3(half_x,0,half_y),
		]
	)
	mesh_data[ArrayMesh.ARRAY_INDEX] = PackedInt32Array(
		[
			1,5,4,
			1,6,5,
			1,2,6,
			2,7,6,
			4,5,9,
			4,9,8,
			5,10,9,
			5,6,10,
			6,11,10,
			6,7,11,
			8,9,13,
			9,14,13,
			9,10,14,
			10,11,14,
		]
	)
	mesh_data[ArrayMesh.ARRAY_TEX_UV] = PackedVector2Array(
		[
			Vector2(0,0),
			Vector2(uv_near,0),
			Vector2(uv_far,0),
			Vector2(1,0),
			Vector2(0,uv_near),
			Vector2(uv_near,uv_near),
			Vector2(uv_far,uv_near),
			Vector2(1,uv_near),
			Vector2(0,uv_far),
			Vector2(uv_near,uv_far),
			Vector2(uv_far,uv_far),
			Vector2(1,uv_far),
			Vector2(0,1),
			Vector2(uv_near,1),
			Vector2(uv_far,1),
			Vector2(1,1),
		]
	)
	
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	$MeshInstance3D.mesh = arr_mesh
	
	# now make the walls
	var side_mesh_x = PlaneMesh.new()
	side_mesh_x.size = Vector2(size.x * (1 - border_radius), size.y)
	var side_mesh_z = PlaneMesh.new()
	side_mesh_z.size = Vector2(size.z * (1 - border_radius), size.y)
	var diag_mesh = PlaneMesh.new()
	diag_mesh.size = Vector2(sqrt(pow(triangle_x,2) + pow(triangle_y,2)), size.y)
	
	$Walls/Left.mesh = side_mesh_z
	$Walls/Right.mesh = side_mesh_z
	$Walls/Top.mesh = side_mesh_x
	$Walls/Bottom.mesh = side_mesh_x
	$Walls/TopLeft.mesh = diag_mesh
	$Walls/BottomLeft.mesh = diag_mesh
	$Walls/TopRight.mesh = diag_mesh
	$Walls/BottomRight.mesh = diag_mesh
	
	$Walls/Top.position = Vector3(0, -size.y*.5, half_y)
	$Walls/Left.position = Vector3(half_x, -size.y*.5, 0)
	$Walls/Bottom.position = Vector3(0, -size.y*.5, -half_y)
	$Walls/Right.position = Vector3(-half_x, -size.y*.5, 0)
	$Walls/TopLeft.position = Vector3(half_x_close + triangle_x * .5, -size.y*.5, half_y_close + triangle_y * .5)
	$Walls/TopRight.position = Vector3(-half_x_close - triangle_x * .5, -size.y*.5, half_y_close + triangle_y * .5)
	$Walls/BottomLeft.position = Vector3(half_x_close + triangle_x * .5, -size.y*.5, -half_y_close - triangle_y * .5)
	$Walls/BottomRight.position = Vector3(-half_x_close - triangle_x * .5, -size.y*.5, -half_y_close - triangle_y * .5)

	$Walls/TopLeft.rotation_degrees.y = angle
	$Walls/BottomLeft.rotation_degrees.y = 180 - angle
	$Walls/TopRight.rotation_degrees.y = -angle
	$Walls/BottomRight.rotation_degrees.y = 180 + angle
