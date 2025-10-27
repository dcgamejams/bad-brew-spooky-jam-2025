extends Node3D

@onready var mesh: QuadMesh = %StartText.mesh
var loading := false

func _process(_delta):
	if Input.is_action_just_pressed("jump") and not loading:
		load_game()
		
func load_game():
	loading = true
	var sasTween: Tween = create_tween()
	sasTween.set_ease(Tween.EASE_OUT)
	sasTween.tween_property(	$AudioStreamPlayer, "volume_db", -35.0, 3.0)

	# TODO: tween this material, but ... gotta move on
	await get_tree().create_timer(0.1).timeout
	%StartText.hide()
	await get_tree().create_timer(0.1).timeout
	%StartText.show()
	await get_tree().create_timer(0.1).timeout
	%StartText.hide()
	await get_tree().create_timer(0.1).timeout
	%StartText.show()
	await get_tree().create_timer(0.1).timeout
	%StartText.hide()
	await get_tree().create_timer(0.1).timeout
	%StartText.show()
	await get_tree().create_timer(0.1).timeout
	%StartText.hide()
	await get_tree().create_timer(0.1).timeout
	%StartText.show()
	await get_tree().create_timer(0.1).timeout
	%StartText.hide()
	await get_tree().create_timer(0.1).timeout
	%StartText.show()
	await get_tree().create_timer(0.1).timeout
	%StartText.hide()
	await get_tree().create_timer(0.1).timeout
	%StartText.show()
	await get_tree().create_timer(0.1).timeout
	%StartText.hide()
	await get_tree().create_timer(0.1).timeout
	%StartText.show()
	await get_tree().create_timer(0.1).timeout
	%StartText.hide()
	await get_tree().create_timer(1.0).timeout
	%MenuMusic.stop()
	$Menu.queue_free()
	%Main.show()
	%Main.start_game()
