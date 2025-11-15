
extends Node3D

@onready var window: Window = get_window()
@onready var player: Player
@onready var player_ui: CanvasLayer = $PlayerUI
@onready var required_item = preload("res://objects/required_item.tscn")
@onready var ingredient = preload("res://objects/ingredient.tscn")
@onready var player_scene = preload("res://PlayerCharacter/PlayerCharacterScene.tscn")

var spawn_timer = Timer.new()
var skull_timer = Timer.new()

var MAX_COUNT = 50

var current_ingredient = Ingredient.TYPE.MUSHROOM: set = set_current_ingredient
var current_round := 0
var multi := 1.0: set = set_multi
var score := 0.0

var streak: int = 0
var max_multi: float = 5.0

func start_game():
	var new_player = player_scene.instantiate()
	new_player.global_position = Vector3(5.0, 12.0, 5.0)
	add_child(new_player, true)
	
	player = get_tree().get_first_node_in_group('Players')

	player.set_process(true)
	player.set_physics_process(true)
	player.godot_plush_skin.set_process(true)

	%MainMusic.play()
	$BubbleNoise.play()
	$PlayerUI.show()
	$Valtestscene.cam()
	
	%CauldronArea.set_collision_mask_value(8, true)
	%CauldronArea.body_entered.connect(on_collect)
	%Kill.body_entered.connect(on_collect_kill)
	%ButtonRestart.pressed.connect(_on_button_restart_pressed)
	%ButtonQuit.pressed.connect(func(): get_tree().quit())

	await get_tree().create_timer(3).timeout
	%LabelStart.text = "GET READY"
	%LabelStart.show()

	await get_tree().create_timer(3).timeout
	%LabelStart.text = "START"
	%LabelStart.show()


	on_round_timer_end()

	await get_tree().create_timer(3).timeout
	%LabelStart.hide()
	%RoundTimer.wait_time = 50.0
	%RoundTimer.timeout.connect(on_round_timer_end)
	%RoundTimer.start()
	
	spawn_timer.wait_time = 1.0
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(spawn_ingredient)
	add_child(spawn_timer)
	spawn_timer.start()

	skull_timer.wait_time = 8.0
	skull_timer.one_shot = false
	skull_timer.timeout.connect(spawn_skull)
	add_child(skull_timer)
	skull_timer.start()



func _process(_delta):
	%LabelTimeRemaining.text = str("%.1f" % %RoundTimer.time_left)	

func on_collect_kill(body):
	if body.is_in_group("Ingredients"):
		%Void.play()
		var collected: Ingredient = body
		collected.queue_free()

func on_collect(body):
	if body.is_in_group("Ingredients"):
		splash()
		var collected: Ingredient = body
		var desired: bool = collected.type == get_current_desired()
		if desired:
			multi = 0.1
			score = score + (100 * multi)
			streak += 1
			%LabelCurrentScore.text = str(int(score)).lpad(8, "0")
		else:
			multi = 0.0
			streak = 0

		collected.remove_ingredient()
		await get_tree().create_timer(0.1).timeout
		if desired: 
			$Good.play() 
		else: 
			if collected.type == Ingredient.TYPE.SKULL and not %RoundTimer.is_stopped():
				if %Hearts.get_child_count() == 1:
					game_over()
				
				%Hearts.get_child(0).queue_free()
	
			$Hurt.play()	


func splash():
	var rand_pitch = randf_range(0.8, 1.2)
	if randi_range(0, 1) == 0:
		$Splash1.pitch_scale = rand_pitch
		$Splash1.play()
	else:
		$Splash2.pitch_scale = rand_pitch
		$Splash2.play()

func set_multi(amount: float):
	if amount == 0.0:
		multi = 0.0
		var blinkTween: Tween = create_tween()
		blinkTween.set_loops(6)
		blinkTween.set_ease(Tween.EASE_IN)
		blinkTween.parallel().tween_property(%LabelCurrentMulti, "modulate:a", 1.0, 0.3).from(0.0)
		blinkTween.parallel().tween_property(%LabelMulti, "modulate:a", 1.0, 0.3).from(0.0)
	else: 
		multi += amount

	multi = clamp(multi, 1.0, max_multi)
	%LabelCurrentMulti.text = str(multi)


# TODO: Setter or emit signal, support multiple ways to end a round
# TODO: "Desired" item. Also, do mixes or patterns even, potentially
func on_round_timer_end():
	for item in %RequiredList.get_children():
		item.queue_free()
	
	%RoundEnd.play()
	current_round += 1
	current_ingredient = randi_range(0, 2) as Ingredient.TYPE

	var new_required: RequiredItem = required_item.instantiate()
	new_required.set_required(current_ingredient)
	new_required.active = true
	%RequiredList.add_child(new_required, true)

func game_over():
	%RoundTimer.stop()
	skull_timer.stop()
	spawn_timer.stop()
	%LabelScore.text = str(int(score))
	%ScoreBoxTop.show()

func set_current_ingredient(chosen_type: Ingredient.TYPE): 
	current_ingredient = chosen_type	

func get_current_desired() -> Ingredient.TYPE: 
	return current_ingredient

func spawn_ingredient():
	if get_tree().get_nodes_in_group("Ingredients").size() > MAX_COUNT:
		return
	
	# TODO: SCALING RULES HERE.
	
	# Every 5 rounds, add an extra ingredient for more chaos!
	@warning_ignore("integer_division")
	for i in randi_range(2, 4):
		await get_tree().create_timer(randf_range(0.2, 0.5)).timeout
		var new_ingredient: Ingredient = ingredient.instantiate()
		var random_radians = randi_range(0, 360)
		new_ingredient.position = get_point_on_circumference(Vector2.ZERO, 16.0, random_radians)
		new_ingredient.initial_angle =  get_point_on_circumference(Vector2.ZERO, 1.0, random_radians - 10)
		new_ingredient.type = get_ingredient_chance(20 + current_round)
		add_child(new_ingredient, true)	
	
	# Optional, we could reduce the time between spawn events by a second each 5 rounds as well
	#@warning_ignore("integer_division")
	#var spawn_timer_reduction = current_round / 5
	@warning_ignore("integer_division")
	spawn_timer.start(randi_range(8, 14 - current_round / 5))

var skull_chance = 35
func spawn_skull():
	if randi_range(0, 100) - current_round > skull_chance:
		var new_ingredient: Ingredient = ingredient.instantiate()
		var random_radians = randi_range(0, 360)
		new_ingredient.position = get_point_on_circumference(Vector2.ZERO, 16.0, random_radians)
		new_ingredient.initial_angle =  get_point_on_circumference(Vector2.ZERO, 1.0, random_radians - 10)
		new_ingredient.type = Ingredient.TYPE.SKULL
		add_child(new_ingredient, true)	


func get_ingredient_chance(neutral_chance) -> Ingredient.TYPE:
	var options = [Ingredient.TYPE.MUSHROOM, Ingredient.TYPE.STAR, Ingredient.TYPE.BERRY]
	options.erase(get_current_desired())

	var roll = randi_range(0, 100)
	# Chance to return a neutral, clamped at 30
	if roll <= neutral_chance: 
		return options[randi_range(0, 1)]
	else:
		## If over the neutral roll, return primary
		return get_current_desired()

func get_point_on_circumference(center: Vector2, radius: float, angle_radians) -> Vector3:
	var x = center.x + radius * cos(angle_radians)
	var y = center.y + radius * sin(angle_radians)

	return Vector3(x, 8.5, y)

func _on_button_restart_pressed() -> void:
	%ScoreBoxTop.hide()
	score = 0.0
	multi = 0.0
	current_round = 0
	skull_timer.start()
	spawn_timer.start()
	%RoundTimer.start()
	pass # Replace with function body.
