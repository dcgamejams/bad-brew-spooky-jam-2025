extends Area3D

@export var is_curved: = false
var active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Cooldown.timeout.connect(func(): active = false)
	$Cooldown.timeout.connect(func(): $Group.show())
	body_entered.connect(activate)
	
func activate(body):
	if body.is_in_group('Players') and active == false:
		active = true
		$Cooldown.start()
		$Group.hide()
		if is_curved: 
			body.boost((-global_transform.basis.z * 0.3 - global_transform.basis.x * 3.0))
		else:
			body.boost(-global_transform.basis.z * 5.0)
