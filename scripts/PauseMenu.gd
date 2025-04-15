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
	if Input.is_action_just_pressed("Escape") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("Escape") and get_tree().paused == true:
		resume()

func _on_resume_button_pressed() -> void:
	resume()


func _on_restart_button_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/main.tscn")  # Adjust the path if your main scene is elsewhere

func _process(delta: float) -> void:
	testEsc()


func _on_menu_button_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
