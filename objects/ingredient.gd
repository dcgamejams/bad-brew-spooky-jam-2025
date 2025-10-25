extends RigidBody3D

@onready var torus_indicator = %TorusIndicator
@onready var shape_cast_floor = %ShapeCastFloor
@onready var ray_cast_down: RayCast3D = %RayCastDown

enum INGREDIENT { 
	GOOD,
	EVIL
}

var is_serving := false	

# Flavor? 
var type: INGREDIENT = INGREDIENT.GOOD
var color: Color = Color.AQUA
var initial_angle := Vector3.ZERO

func _ready() -> void:
	add_to_group("Ingredients")
	
	# Layer	
	set_collision_layer_value(1, false)
	set_collision_layer_value(8, true)
	
	# Mask
	set_collision_mask_value(1, true)

	shape_cast_floor.top_level = true
	torus_indicator.top_level = true
	ray_cast_down.top_level = true

	await get_tree().create_timer(0.2).timeout
	var rand_v = randf_range(-4.0, 4.0) * Vector3(1.0, -0.5, 1.0)

	var BLAST = 8.0
	apply_central_force(rand_v * BLAST)
	apply_torque(initial_angle * 5.0)

	if randi_range(0, 2) == 0:
		type = INGREDIENT.EVIL
		color = Color.CRIMSON
		set_mesh_color(Color.CRIMSON)

func set_mesh_color(new_color: Color):
	var mesh_material: StandardMaterial3D = $MeshInstance3D.get_active_material(0)
	var new_mat = mesh_material.duplicate() 
	new_mat.albedo_color = new_color
	new_mat.albedo_color.a = 0.3
	new_mat.emission = new_color
	$MeshInstance3D.set_surface_override_material(0, new_mat)

func _process(_delta: float) -> void:
	move_ray_casts()
	check_collision()

func move_ray_casts():
	ray_cast_down.position = position + Vector3(0.0, 40.0, 0.0)
	shape_cast_floor.position = global_position
	
func check_collision():
	if ray_cast_down.is_colliding():
		torus_indicator.position = ray_cast_down.get_collision_point()

	if ray_cast_down.is_colliding:
		line(global_position, ray_cast_down.get_collision_point(), color)

	if shape_cast_floor.is_colliding():
		var dist_factor = position.distance_to(Vector3.ZERO) / 10
		apply_central_force((position.direction_to(Vector3.ZERO + initial_angle)) * dist_factor)
		
		
	
func get_random_point_in_square(pos: Vector2, size: Vector2) -> Vector2:
	# Generate a random X coordinate within the square's horizontal bounds
	var random_x = randf_range(pos.x, pos.x + size.x)
	# Generate a random Y coordinate within the square's vertical bounds
	var random_y = randf_range(pos.y, pos.y + size.y)
	return Vector2(random_x, random_y)	


func line(pos1: Vector3, pos2: Vector3, color = Color.AQUA, persist_ms = 1):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await final_cleanup(mesh_instance, persist_ms)
	
func final_cleanup(mesh_instance: MeshInstance3D, persist_ms: float):
	get_tree().get_root().add_child(mesh_instance)
	if persist_ms == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif persist_ms > 0:
		await get_tree().create_timer(persist_ms).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
