extends RigidBody3D

class_name Ingredient

@onready var torus_indicator = %TorusIndicator
@onready var shape_cast_floor = %ShapeCastFloor
@onready var ray_cast_down: RayCast3D = %RayCastDown
@onready var torque_timer: Timer = $TorqueTimer
@onready var death_timer: Timer = $DeathTimer

enum TYPE { 
	MUSHROOM, #0
	STAR, # 1
	BERRY, # 2 
	SKULL,# 4+
}

var COLORS: Array[Color] = [Color.AQUA, Color.YELLOW, Color.BLUE, Color.CRIMSON]

# TODO: Rename to "Flavor"
var type : TYPE = TYPE.MUSHROOM : set = set_type
var color: Color
var initial_angle := Vector3.ZERO
var is_showing_line := false

var con_torque = randf_range(2.0, 1.9)

func _ready() -> void:
	add_to_group("Ingredients")
	
	# Layer	
	set_collision_layer_value(1, true)
	set_collision_layer_value(8, true)
	
	# Mask
	set_collision_mask_value(1, true)

	shape_cast_floor.top_level = true
	torus_indicator.top_level = true
	ray_cast_down.top_level = true

	await get_tree().create_timer(0.2).timeout
	var rand_v = randf_range(-4.0, 4.0) * Vector3(1.0, -0.5, 1.0)

	var BLAST = randf_range(5, 10)
	apply_central_force(rand_v * BLAST)
	apply_torque_impulse(initial_angle * randf_range(3.0, 5.0))

	torque_timer.wait_time = randf_range(3, 5.0)
	death_timer.wait_time = randf_range(15, 20)

func set_type(value: TYPE):
	type = value
	match value: 
		TYPE.MUSHROOM:
			%Mushroom.show()
		TYPE.STAR:
			%Star.show()
		TYPE.BERRY:
			%Berry.show()	
		TYPE.SKULL:
			%Skull.show()
			con_torque += 0.5
	
func _process(_delta: float) -> void:
	move_ray_casts()
	check_collision()
	%Icons.position = global_position

func move_ray_casts():
	ray_cast_down.position = position + Vector3(0.0, 40.0, 0.0)
	shape_cast_floor.position = global_position

func stop():
	if not torque_timer.is_stopped():
		torque_timer.stop()
	await get_tree().process_frame
	if not is_inside_tree():
		return
	freeze = true
	set_angular_velocity(Vector3.ZERO)
	await get_tree().process_frame
	if not is_inside_tree():
		return
	freeze = false


func check_collision():
	if ray_cast_down.is_colliding():
		torus_indicator.position = ray_cast_down.get_collision_point()

	if shape_cast_floor.is_colliding():
		#var _center = Vector3(0.0, 3.2, 0.0)
	
		#if death_timer.is_stopped() and position.distance_to(center) < 9.0:
			#apply_central_force((position.direction_to(center)) * 10.0)
			#return		

		#var dist_factor = position.distance_to(center) / 20
		#apply_central_force((position.direction_to(center + initial_angle)) * dist_factor)
		if not torque_timer.is_stopped():
			apply_torque(initial_angle * con_torque)
			
func get_random_point_in_square(pos: Vector2, size: Vector2) -> Vector2:
	# Generate a random X coordinate within the square's horizontal bounds
	var random_x = randf_range(pos.x, pos.x + size.x)
	# Generate a random Y coordinate within the square's vertical bounds
	var random_y = randf_range(pos.y, pos.y + size.y)
	return Vector2(random_x, random_y)	

func remove_ingredient():
	if not torque_timer.is_stopped(): torque_timer.stop()
	set_collision_layer_value(1, false)
	set_collision_layer_value(8, false)
	await stop()
	apply_torque(initial_angle * con_torque)
	await get_tree().create_timer(1.2).timeout	
	set_collision_mask_value(1, false)
	await get_tree().create_timer(0.5).timeout
	queue_free()
