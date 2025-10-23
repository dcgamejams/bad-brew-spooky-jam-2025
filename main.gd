extends Node3D

@export var stationary_cam := false
@onready var window: Window = get_window()

func _ready() -> void:
	%Floor.set_collision_layer_value(5, true)
	
	if stationary_cam: 
		%StationaryCamera.current = true
