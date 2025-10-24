extends Node3D

@export var stationary_cam := false
@onready var window: Window = get_window()

func _ready() -> void:
	%Floor.set_collision_layer_value(5, true)
	
	if stationary_cam: 
		%StationaryCamera.current = true
		%StationaryCamera.add_to_group("StationaryCam")

#func _process(_delta: float) -> void:
	#if stationary_cam:
		#var player = get_tree().get_first_node_in_group('Players')
		#%StationaryCamera.look_at(player.position)
