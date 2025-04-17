extends Control

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	hide()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished  # Wait for animation to finish
	hide()  # Hide the pause menu after unpausing
	
func pause():
	get_tree().paused = true
	show()
	$AnimationPlayer.play("blur")
	
func testEsc():
	if GameState.is_game_over:
		return  # Don't allow pause toggling during game over

	if Input.is_action_just_pressed("Escape"):
		if get_tree().paused == false:
			pause()
		elif get_tree().paused == true:
			resume()

func _on_resume_button_pressed() -> void:
	$SelectSound.play()
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	resume()


func _on_restart_button_pressed() -> void:
	$SelectSound.play()
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	resume()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _process(delta: float) -> void:
	testEsc()


func _on_menu_button_pressed() -> void:
	$SelectSound.play()
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	resume()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_resume_button_mouse_entered() -> void:
	$HoverSound.play()


func _on_restart_button_mouse_entered() -> void:
	$HoverSound.play()


func _on_menu_button_mouse_entered() -> void:
	$HoverSound.play()
