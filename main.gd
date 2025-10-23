extends Node3D

@onready var window: Window = get_window()

func _ready() -> void:
	%Floor.set_collision_layer_value(5, true)
