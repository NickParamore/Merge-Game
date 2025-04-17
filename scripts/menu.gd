extends Control

@onready var clouds: Sprite2D = $Clouds

var bob_speed = 1.5
var bob_amplitude = 5.0
var original_y = 820
var time_passed = 0.0
	
func _process(delta):
	time_passed += delta
	clouds.position.y = original_y + sin(time_passed * bob_speed) * bob_amplitude
	
func _on_start_button_pressed() -> void:
	$SelectSound.play()
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed() -> void:
	$SelectSound.play()
	set_process_input(false)
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()


func _on_start_button_mouse_entered() -> void:
	$HoverSound.play()


func _on_quit_button_mouse_entered() -> void:
	$HoverSound.play()
