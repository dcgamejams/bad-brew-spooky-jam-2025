extends Node3D

@onready var mesh: QuadMesh = %StartText.mesh
var main_scene = preload("res://main.tscn")
var loading := false

func _process(_delta):
	if Input.is_action_just_pressed("jump") and not loading:
		load_game()
		
func load_game():
	loading = true
	# TODO: tween
	var sasTween: Tween = create_tween()
	sasTween.set_ease(Tween.EASE_OUT)
	sasTween.tween_property(	$AudioStreamPlayer, "volume_db", -30.0, 2.0)
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
	get_tree().change_scene_to_packed(main_scene)
