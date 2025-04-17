extends Control

var is_game_over = false

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	hide()

func set_game_over():
	is_game_over = true
	get_tree().paused = true
	show()
	$AnimationPlayer.play("blur")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	hide()

func _on_menu_button_pressed() -> void:
	$SelectSound.play()
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	GameState.is_game_over = false
	resume()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_restart_button_pressed() -> void:
	$SelectSound.play()
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	GameState.is_game_over = false
	resume()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_restart_button_mouse_entered() -> void:
	$HoverSound.play()


func _on_menu_button_mouse_entered() -> void:
	$HoverSound.play()
