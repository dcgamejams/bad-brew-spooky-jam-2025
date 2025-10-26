extends Marker3D

@onready var ingredient = preload("res://objects/ingredient.tscn")

var timer = Timer.new()
var RANGE = 12.0
var MAX = 50.0

func _ready() -> void:
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(spawn_ingredient)
	add_child(timer)
	timer.start()
	
func spawn_ingredient():
	if get_tree().get_nodes_in_group("Balls").size() > MAX:
		return
	
	for i in randi_range(4, 9):
		await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
		var new_ingredient: Ingredient = ingredient.instantiate()
		var random_radians = randi_range(0, 360)
		new_ingredient.position = get_point_on_circumference(Vector2.ZERO, 18.0, random_radians)
		new_ingredient.initial_angle =  get_point_on_circumference(Vector2.ZERO, 1.0, random_radians - 10)
		new_ingredient.type = get_ingredient_chance()
		add_child(new_ingredient, true)
	
	timer.start(randi_range(8, 15))

# TODO: Secret sauce: adjust ratio of incoming ingredients based on current round
func get_ingredient_chance() -> Ingredient.TYPE:
	if randi_range(0, 1) == 0:
		return Ingredient.TYPE.MUSHROOM
	else:
		return Ingredient.TYPE.SKULL

func get_point_on_circumference(center: Vector2, radius: float, angle_radians) -> Vector3:
	var x = center.x + radius * cos(angle_radians)
	var y = center.y + radius * sin(angle_radians)
	return Vector3(x, 8.5, y)
	
