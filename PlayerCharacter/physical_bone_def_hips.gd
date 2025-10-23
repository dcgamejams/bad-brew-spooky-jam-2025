extends PhysicalBone3D

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Input.is_action_pressed("secondary"):
		state.linear_velocity = Vector3.ZERO
