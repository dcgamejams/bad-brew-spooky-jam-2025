extends CharacterBody3D

class_name Player


#movement variables
var move_speed : float
var move_accel : float
var move_deccel : float
var move_dir : Vector2
var target_angle : float
var last_input_dir : Vector2
var last_frame_position : Vector3
var last_frame_velocity : Vector3
var was_on_floor : bool = false
var walk_or_run : String = "RunState" #keep in memory if play char was walking or running before being in the air

# default walk_deccel: 7.5
# default walk_deccel: 6.5

@export_group("Walk variables")
@export var walk_speed : float
@export var walk_accel : float
@export var walk_deccel : float

@export_group("Run variables")
@export var run_speed : float
@export var run_accel : float
@export var run_deccel : float
@export var continious_run : bool = false #if true, doesn't need to keep run button on to run

@export_group("Jump variables")
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
var has_cut_jump : bool = false
@export var jump_cut_multiplier : float
@export var jump_cooldown : float
var jump_cooldown_ref : float 
@export var nb_jumps_in_air_allowed : int 
var nb_jumps_in_air_allowed_ref : int
var jump_buff_on : bool = false
var buffered_jump : bool = false
@export var coyote_jump_cooldown : float
var coyote_jump_cooldown_ref : float
var coyote_jump_on : bool = false
@export var auto_jump : bool = false
 
@export_group("In air variables")
@export var in_air_move_speed : Array[Curve]
@export var in_air_accel : Array[Curve]
@export var hit_wall_cut_velocity : bool = false

#gravity variables
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@export_group("Keybinding variables")
@export var moveForwardAction : String = ""
@export var moveBackwardAction : String = ""
@export var moveLeftAction : String = ""
@export var moveRightAction : String = ""
@export var runAction : String = ""
@export var jumpAction : String = ""

@export_group("Model variables")
@export var model_rot_speed : float
@export var ragdoll_gravity : float
@export var ragdoll_on_floor_only : bool = false
@export var follow_cam_pos_when_aimed : bool = false

#references variables
@onready var visual_root = %VisualRoot
@onready var godot_plush_skin = %GodotPlushSkin
@onready var particles_manager = %ParticlesManager
@onready var cam_holder = $OrbitView
@onready var state_machine = $StateMachine
@onready var debug_hud = %DebugHUD
@onready var foot_step_audio = %FootStepAudio
@onready var impact_audio = %ImpactAudio
@onready var wave_audio = %WaveAudio
@onready var collision_shape_3d = %CollisionShape3D
@onready var floor_check : RayCast3D = %FloorRaycast

@onready var mouse_mesh: MeshInstance3D = %Mouse


#particles variables
@onready var movement_dust = %MovementDust
@onready var jump_particles = preload("res://PlayerCharacter/Vfx/jump_particles.tscn")
@onready var land_particles = preload("res://PlayerCharacter/Vfx/land_particles.tscn")


# ADDED:
@onready var slam_scene = preload("res://PlayerCharacter/Vfx/slam_effect.tscn")
@onready var world = get_tree().current_scene

var immobile := false

func _enter_tree() -> void:
	set_multiplayer_authority(1)

func _ready():
	add_to_group('Players')
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)


	
	#set move variables, and value references
	move_speed = walk_speed
	move_accel = walk_accel
	move_deccel = walk_deccel
	
	jump_cooldown_ref = jump_cooldown
	nb_jumps_in_air_allowed_ref = nb_jumps_in_air_allowed
	coyote_jump_cooldown_ref = coyote_jump_cooldown
	
	%KickArea.body_entered.connect(kick_object)
	%Stop.body_entered.connect(stop)
	
	#set char model audios effects
	godot_plush_skin.footstep.connect(func(intensity : float = 1.0):
		foot_step_audio.volume_db = linear_to_db(intensity)
		foot_step_audio.play()
		)

func display_mouse():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(Vector3(0, 0, 0), Vector3(50, 0.0, 100))
	var result = space_state.intersect_ray(query)
	%Mouse.position = get_mouse(result).position

func _process(delta: float):
	modify_model_orientation(delta)
	display_properties()
	
func _physics_process(_delta : float):
	kick()
	modify_physics_properties()
	move_and_slide()
	display_mouse()
	
func display_properties():
	#display play char properties
	debug_hud.display_curr_state(state_machine.curr_state_name)
	debug_hud.display_velocity(velocity.length())
	debug_hud.display_nb_jumps_in_air_allowed(nb_jumps_in_air_allowed)
	debug_hud.display_jump_buffer(jump_buff_on)
	debug_hud.display_coyote_time(coyote_jump_cooldown)
	debug_hud.display_model_orientation(cam_holder.cam_aimed and follow_cam_pos_when_aimed)
	debug_hud.display_camera_mode(cam_holder.cam_aimed)
	
func modify_model_orientation(delta : float):
	#manage the model rotation depending on the camera mode + char parameters
	
	var dir_target_angle : float
	
	#follow mode (model must follow the camera rotation)
	#if the cam is in angled/aim mode
	if cam_holder.cam_aimed and follow_cam_pos_when_aimed and !godot_plush_skin.ragdoll:
		#get cam rotation on the y axis (+ PI to invert half circle, and be sure that the model is correctly oriented)
		dir_target_angle = (cam_holder.cam.global_rotation.y) + PI
		#rotate the model on the y axis
		visual_root.rotation.y = rotate_toward(visual_root.rotation.y, dir_target_angle, model_rot_speed * delta)
	
	#free mode (the model orientation is independant to the camera one)
	if (!cam_holder.cam_aimed or !follow_cam_pos_when_aimed) and move_dir != Vector2.ZERO:
		#get char move direction
		dir_target_angle = -move_dir.orthogonal().angle()
		#rotate the model on the y axis
		visual_root.rotation.y = rotate_toward(visual_root.rotation.y, dir_target_angle, model_rot_speed * delta)
		
func modify_physics_properties():
	last_frame_position = position #get play char position every frame
	last_frame_velocity = velocity #get play char velocity every frame
	was_on_floor = !is_on_floor() #get if play char is on floor or not
	#godot_plush_skin.torus.visible = !is_on_floor()
	
func gravity_apply(delta : float):
	#if play char goes up, apply jump gravity
	#otherwise, apply fall gravity
	if velocity.y >= 0.0: velocity.y -= jump_gravity * delta
	elif velocity.y < 0.0: velocity.y -= fall_gravity * delta

func squash_and_strech(value : float, timing : float):
	#create a tween that simulate a compression of the model (squash and strech ones)
	#maily used to accentuate game feel/juice
	#call the squash_and_strech function of the model (it's this function that actually squash and strech the model)
	var sasTween : Tween = create_tween()
	sasTween.set_ease(Tween.EASE_OUT)
	sasTween.tween_property(godot_plush_skin, "squash_and_stretch", value, timing)
	sasTween.tween_property(godot_plush_skin, "squash_and_stretch", 1.0, timing * 1.8)
	
func kick_and_stretch(value : float, timing : float):
	#create a tween that simulate a compression of the model (squash and strech ones)
	#maily used to accentuate game feel/juice
	#call the squash_and_strech function of the model (it's this function that actually squash and strech the model)
	var kickTween : Tween = create_tween()
	kickTween.set_ease(Tween.EASE_OUT)
	kickTween.tween_property(godot_plush_skin, "kick_value", value, timing)
	kickTween.tween_property(godot_plush_skin, "kick_value", 1.0, timing * 1.8)

func slam_down():
	squash_and_strech(-0.1, 0.1)
	particles_manager.display_particles(jump_particles, self)
	var new_slam = slam_scene.instantiate()
	new_slam.position = floor_check.get_collision_point()
	world.add_child(new_slam, true)
	godot_plush_skin.slam_area.get_node('CollisionShape3D').disabled = false
	%KickArea.get_node("CollisionShape3D").disabled = false
	$Slam.play()
	await get_tree().create_timer(0.2).timeout 
	godot_plush_skin.slam_area.get_node('CollisionShape3D').disabled = true
	%KickArea.get_node("CollisionShape3D").disabled = true

var items: int = 0
signal signal_item_picked_up

func add_item():
	signal_item_picked_up.emit()
	items += 1
	%LabelItemCount.text = str(items)

func boost(dir):
	var center: PhysicalBone3D = godot_plush_skin.center_body
	center.apply_central_impulse(dir)

func kick():
	if Input.is_action_just_pressed('kick') and $KickTimer.is_stopped():
		$Kick.play()
		kick_and_stretch(0.05, 0.05)
		%KickArea.get_node("CollisionShape3D").disabled = false
		await get_tree().create_timer(0.1).timeout 
		%KickArea.get_node("CollisionShape3D").disabled = true
		$KickTimer.start()

func kick_object(body):
	if body.is_in_group("Ingredients"):
		var item: Ingredient = body
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(Vector3(0, 0, 0), Vector3(50, 0.0, 100))
		var result = space_state.intersect_ray(query)
		
		#var player_dir = %VisualRoot.global_transform.basis.z
		var mouse_dir = item.position.direction_to(get_mouse(result).position)
		if not item.torque_timer.is_stopped():
			item.torque_timer.stop()
			item.apply_torque_impulse(item.initial_angle * -item.con_torque * 1.15)
		if get_mouse(result).position.distance_to(Vector3.ZERO) < 4.0:
			print('tried')
			item.apply_central_impulse(item.position.direction_to(Vector3(0.0, 0.5, 0.0)) * 12.0) #apply 
		else:
			item.apply_central_impulse(mouse_dir * 15.0) #apply 
		
func stop(body):
	if body.is_in_group("Ingredients"):
		$Hit.play()
		var item: Ingredient = body
		if not item.torque_timer.is_stopped():
			item.torque_timer.stop()
			item.apply_torque_impulse(item.initial_angle * -item.con_torque * 1.15)
		#item.apply_central_impulse(item.global_position.direction_to(Vector3.ZERO) * 1.0) #apply 
		await get_tree().create_timer(0.2).timeout		
		
func get_mouse(_rid_wall):
	var space_state = get_world_3d().direct_space_state
	var cam = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var RAY_LENGTH = 1000.0
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	query.exclude = [self]
		
	return space_state.intersect_ray(query)
