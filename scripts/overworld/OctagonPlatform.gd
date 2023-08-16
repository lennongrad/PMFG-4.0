@tool

extends Node3D

@export var size: Vector3: set = updateSize
@export_range(0, 1, 0.05) var border_radius: float: set = updateRadius
@export var main_texture: CompressedTexture2D: set = updateTexture
@export var side_texture: CompressedTexture2D: set = updateSideTexture
@export var uvScaleTop: Vector2 = Vector2(1,1): set = updateScaleTop
@export var uvScale: Vector2 = Vector2(1,1): set = updateScale

func updateSize(newSize):
	size = newSize
	updateMesh()

func updateRadius(newRadius):
	border_radius = newRadius
	updateMesh()

func updateTexture(newTexture):
	main_texture = newTexture
	updateMesh()

func updateSideTexture(newTexture):
	side_texture = newTexture
	updateMesh()

func updateScaleTop(newScale):
	uvScaleTop =newScale
	updateMesh()

func updateScale(newScale):
	uvScale =newScale
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
	var hypotenuse = sqrt(pow(triangle_x,2) + pow(triangle_y,2))
	var bisector = triangle_x * triangle_y * sqrt(2) / (triangle_x + triangle_y)
	
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
	mesh_data[ArrayMesh.ARRAY_NORMAL] = PackedVector3Array(
		[
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
			Vector3(0,1,0),
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
	$MeshInstance3D.material_override = StandardMaterial3D.new()
	$MeshInstance3D.material_override.albedo_texture = main_texture
	$MeshInstance3D.material_override.texture_filter = 0
	$MeshInstance3D.material_override.uv1_scale.x = size.x * uvScaleTop.x
	$MeshInstance3D.material_override.uv1_scale.y = size.z * uvScaleTop.y
	
	# now make the walls
	var side_mesh_x = PlaneMesh.new()
	side_mesh_x.size = Vector2(size.x * (1 - border_radius), size.y)
	side_mesh_x.material = StandardMaterial3D.new()
	side_mesh_x.material.albedo_texture = side_texture
	side_mesh_x.material.texture_filter = 0
	side_mesh_x.material.uv1_scale.x = floor(size.x * uvScale.x)
	side_mesh_x.material.uv1_scale.y = size.y * uvScale.y
	
	var side_mesh_z = PlaneMesh.new()
	side_mesh_z.size = Vector2(size.z * (1 - border_radius), size.y)
	side_mesh_z.material = StandardMaterial3D.new()
	side_mesh_z.material.albedo_texture = side_texture
	side_mesh_z.material.texture_filter = 0
	side_mesh_z.material.uv1_scale.x = floor(size.x * uvScale.x)
	side_mesh_z.material.uv1_scale.y = size.y * uvScale.y
	
	var diag_mesh = PlaneMesh.new()
	diag_mesh.size = Vector2(hypotenuse, size.y)
	diag_mesh.material = StandardMaterial3D.new()
	diag_mesh.material.albedo_texture = side_texture
	diag_mesh.material.texture_filter = 0
	diag_mesh.material.uv1_scale.x = (size.x * uvScale.x * border_radius * .5)
	diag_mesh.material.uv1_scale.y = (size.y * uvScale.y)
	
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

	# finally make the collision
	$HorizontalShape.shape = BoxShape3D.new()
	$HorizontalShape.position = Vector3(0,-size.y*.5,0)
	$HorizontalShape.shape.size = Vector3(size.x, size.y, half_y_close * 2)
	$SideShape.shape = BoxShape3D.new()
	$SideShape.position = Vector3(0,-size.y*.5,0)
	$SideShape.shape.size = Vector3(half_x_close * 2, size.y, size.z)
	
	var perpindicular = Vector2(bisector/2,0).rotated((angle - 90)/180 * PI)
	
	$TopLeftShape.shape = BoxShape3D.new()
	$TopLeftShape.position = Vector3(
		-half_x_close - triangle_x/2 + perpindicular.x,
		-size.y*.5,
		-half_y_close - triangle_y/2 - perpindicular.y)
	$TopLeftShape.shape.size = Vector3(hypotenuse, size.y, bisector)
	$TopLeftShape.rotation_degrees.y = angle
	
	$TopRightShape.shape = BoxShape3D.new()
	$TopRightShape.position = Vector3(
		half_x_close + triangle_x/2 - perpindicular.x,
		-size.y*.5,
		-half_y_close - triangle_y/2 - perpindicular.y)
	$TopRightShape.shape.size = Vector3(hypotenuse, size.y, bisector)
	$TopRightShape.rotation_degrees.y = -angle

	$BottomLeftShape.shape = BoxShape3D.new()
	$BottomLeftShape.position = Vector3(
		-half_x_close - triangle_x/2 + perpindicular.x,
		-size.y*.5,
		half_y_close + triangle_y/2 + perpindicular.y)
	$BottomLeftShape.shape.size = Vector3(hypotenuse, size.y, bisector)
	$BottomLeftShape.rotation_degrees.y = -angle

	$BottomRightShape.shape = BoxShape3D.new()
	$BottomRightShape.position = Vector3(
		half_x_close + triangle_x/2 - perpindicular.x,
		-size.y*.5,
		half_y_close + triangle_y/2 + perpindicular.y)
	$BottomRightShape.shape.size = Vector3(hypotenuse, size.y, bisector)
	$BottomRightShape.rotation_degrees.y = angle
