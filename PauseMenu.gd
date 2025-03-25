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


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	testEsc()
