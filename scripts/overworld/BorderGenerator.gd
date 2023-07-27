@tool

extends StaticBody3D

@export var borderTexture: CompressedTexture2D: set = updateBorders
@export var mainTexture: CompressedTexture2D: set = updateMain
@export var secondaryTexture: CompressedTexture2D: set = updateSecondary
@export var size: Vector3: set = updateSize

var counter = 0

func _process(_delta):
	counter += 1
	if counter > 100:
		counter = 0
		updateMain(mainTexture)
		updateSecondary(secondaryTexture)

func updateMain(newMain):
	mainTexture = newMain
	if not has_node("MainMesh"):
		return
	$MainMesh.material_override.albedo_texture = mainTexture

func updateSecondary(newSecondary):
	secondaryTexture = newSecondary
	if not has_node("SecondaryMesh"):
		return
	$SecondaryMesh.material_override.albedo_texture = secondaryTexture

func updateSize(newSize):
	if not has_node("MainMesh"):
		return
	size = newSize
	
	$MainMesh.material_override = StandardMaterial3D.new()
	$MainMesh.material_override.albedo_texture = mainTexture
	$MainMesh.mesh = BoxMesh.new()
	
	$SecondaryMesh.material_override = StandardMaterial3D.new()
	$SecondaryMesh.material_override.albedo_texture = secondaryTexture
	$SecondaryMesh.mesh = BoxMesh.new()
	
	$CollisionShape3D.shape = BoxShape3D.new()
	$CollisionShape3D.shape.size = newSize
	
	$MainMesh.mesh.size = newSize
	$MainMesh.material_override.uv1_scale.x = size.x * 2
	$MainMesh.material_override.uv1_scale.y = size.z * 2
	
	$SecondaryMesh.mesh.size = newSize
	$SecondaryMesh.mesh.size.x += .01
	$SecondaryMesh.mesh.size.y -= .01
	$SecondaryMesh.mesh.size.z += .01
	$SecondaryMesh.material_override.uv1_scale.x = size.x * 2
	$SecondaryMesh.material_override.uv1_scale.y = size.z * 2
	
	updateBorders(borderTexture)

func updateBorders(newBorder):
	borderTexture = newBorder
	if has_node("BorderMeshes"):
		for i in range(0, $BorderMeshes.get_child_count()):
			$BorderMeshes.get_child(i).queue_free()
		
		for e in range(0, 3):
			var mesh = BoxMesh.new()
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = borderTexture
			match e:
				0: 
					mesh.size = Vector3(size.x, .2, .2)
					mat.uv1_scale.x = size.x * 4
				1: 
					mesh.size = Vector3(size.y, .2, .2)
					mat.uv1_scale.x = size.y * 4
				2: 
					mesh.size = Vector3(size.z, .2, .2)
					mat.uv1_scale.x = size.z * 4
			for i in range(0,4):
				var meshIns = MeshInstance3D.new()
				meshIns.mesh = mesh
				meshIns.position = size / 2 - Vector3(1,1,1) * .09 + Vector3(1,1,1) * e * .005
				meshIns.material_override = mat
				match e:
					0: 
						meshIns.position *= Vector3(0, 1 - 2 * round((i)/2), 1 - 2 * (i % 2))
					1: 
						meshIns.position *= Vector3(1 - 2 * round((i)/2), 0, 1 - 2 * (i % 2))
						meshIns.rotation_degrees.z = 90
					2: 
						meshIns.position *= Vector3(1 - 2 * round((i)/2), 1 - 2 * (i % 2), 0)
						meshIns.rotation_degrees.y = 90
				$BorderMeshes.add_child(meshIns)
				meshIns.set_owner(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
