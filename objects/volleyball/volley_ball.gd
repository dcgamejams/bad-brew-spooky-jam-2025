extends RigidBody3D

@onready var torus_indicator = %TorusIndicator
@onready var shape_cast_floor = %ShapeCastFloor
@onready var ray_cast_down: RayCast3D = %RayCastDown

var is_serving := false	
var is_showing_line := false

func _ready() -> void:
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true) # Paddle collision

	shape_cast_floor.set_collision_mask_value(1, false)
	shape_cast_floor.set_collision_mask_value(5, true)
	shape_cast_floor.top_level = true

	torus_indicator.top_level = true
	
	await get_tree().create_timer(0.2).timeout
	var rand_v = randf_range(-4.0, 4.0) * Vector3(1.0, -0.5, 1.0)
	
	var BLAST = 250.0
	apply_central_force(rand_v * BLAST)

	%PickupArea.body_entered.connect(on_pickup)
	
	await get_tree().create_timer(0.3).timeout
	is_showing_line = true
	
	#if not is_multiplayer_authority():
		#set_process(false)
		#set_physics_process(false)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		apply_central_force(Vector3.UP * 500.0)

	move_ray_casts()
	check_collision()

func move_ray_casts():
	ray_cast_down.position = position
	shape_cast_floor.position = position
	

func check_collision():
	if ray_cast_down.is_colliding():
		torus_indicator.position = ray_cast_down.get_collision_point()
		#torus_indicator.scale = position.distance_to(ray_cast_down.get_collision_point())
		#print(ray_cast_down.is_colliding())
		#print(ray_cast_down.get_collision_point())
		
	if shape_cast_floor.is_colliding() == false and is_showing_line:
		line(global_position, ray_cast_down.get_collision_point())
		#var collision_obj = shape_cast_floor.get_collider(0)
		#print('[Debug]: Ball on floor: ', collision_obj)
		#serve_ball()

func serve_ball():
	is_serving = true
	freeze = true
	var rand_pos = get_random_point_in_square(Vector2(0, 0), Vector2(10.0, 10.0))
	var serve_height = 10.0	
	# Note: x, y, z, but we use the 2D square, excercise caution.
	position = Vector3(rand_pos.x, serve_height, rand_pos.y)
	await get_tree().create_timer(0.1).timeout
	is_serving = false
	freeze = false

func get_random_point_in_square(pos: Vector2, size: Vector2) -> Vector2:
	# Generate a random X coordinate within the square's horizontal bounds
	var random_x = randf_range(pos.x, pos.x + size.x)
	# Generate a random Y coordinate within the square's vertical bounds
	var random_y = randf_range(pos.y, pos.y + size.y)

	return Vector2(random_x, random_y)	

func on_pickup(body):
	if body.is_in_group('Players'):
		body.add_item()
		#if Engine.is_editor_hint() == false:
			#queue_free()


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
