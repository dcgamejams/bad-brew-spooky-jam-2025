extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_pickup)

func on_pickup(body):
	if body.is_in_group('Players'):
		body.add_item()
		queue_free()	
