@tool

extends StaticBody3D

@export var main_texture: CompressedTexture2D: set = updateTexture
@export var size: Vector2: set = updateSize
@export var uvScale: Vector2 = Vector2(1,1): set = updateScale

func updateTexture(newTexture):
	main_texture = newTexture
	updateMesh()

func updateSize(newSize):
	size = newSize
	updateMesh()

func updateScale(newScale):
	uvScale = newScale
	updateMesh()

func updateMesh():
	if not has_node("MeshInstance3D"):
		return

	$CollisionShape3D.shape = BoxShape3D.new()
	$CollisionShape3D.shape.size = Vector3(size.x, .1, size.y)


	$MeshInstance3D.material_override = StandardMaterial3D.new()
	$MeshInstance3D.material_override.albedo_texture = main_texture
	$MeshInstance3D.material_override.texture_filter = 0
	$MeshInstance3D.mesh = BoxMesh.new()
	$MeshInstance3D.mesh.size = Vector3(size.x, .01, size.y)
	$MeshInstance3D.material_override.uv1_scale.x = size.x * uvScale.x
	$MeshInstance3D.material_override.uv1_scale.y = size.y * uvScale.y
