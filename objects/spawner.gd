extends Marker3D

@onready var ball = preload("res://objects/volleyball/volley_ball.tscn")

var timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(spawn_ball)
	add_child(timer)
	timer.start()
	
func spawn_ball():
	for i in randi_range(5, 12):
		var new_pickup = ball.instantiate()
		new_pickup.position = Vector3(randf_range(-100.0, 100.0), 30.0, randf_range(-100.0, 100.0))
		add_child(new_pickup, true)
	
	timer.start(randi_range(8, 15))
