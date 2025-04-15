extends Control

@onready var clouds: Sprite2D = $Clouds

var bob_speed = 1.5
var bob_amplitude = 5.0
var original_y = 820
var time_passed = 0.0

func _ready():
	$VBoxContainer/StartButton.grab_focus()
	
func _process(delta):
	time_passed += delta
	clouds.position.y = original_y + sin(time_passed * bob_speed) * bob_amplitude
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
