extends Control

@onready var resolution_option_button: OptionButton = $Panel/HBoxContainer/VBoxContainer/OptionButton
@onready var check_box: CheckBox = $Panel/HBoxContainer/VBoxContainer/CheckBox

var resolutions = {
	"3840x2160": Vector2i(3840,2160),
	"2560x1440": Vector2i(2560,1440),
	"1920x1080": Vector2i(1920,1080),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1440x900": Vector2i(1440,900),
	"1600x900": Vector2i(1600,900),
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600)
}

func _ready():
	add_resolutions()
	check_variables()

func check_variables():
	var window = get_window()
	var mode = window.get_mode()

	if mode == Window.MODE_FULLSCREEN:
		check_box.set_pressed_no_signal(true)
	else:
		check_box.set_pressed_no_signal(false)
		set_resolution_text()  # Update resolution text for windowed mode

func set_resolution_text():
	var window_size = get_window().get_size()
	var resolution_text = "%dx%d" % [window_size.x, window_size.y]
	resolution_option_button.set_text(resolution_text)

func add_resolutions():
	var current_resolution = get_window().get_size()
	var id = 0
	
	for res_text in resolutions.keys():
		resolution_option_button.add_item(res_text, id)
		if resolutions[res_text] == current_resolution:
			resolution_option_button.select(id)
		id += 1

func _on_option_button_item_selected(index: int) -> void:
	var selected_text = resolution_option_button.get_item_text(index)
	var new_size = resolutions.get(selected_text, get_window().get_size())  # Fallback in case of error
	get_window().set_size(new_size)

	await get_tree().process_frame  # Wait for resizing to apply
	center_window()
	set_resolution_text()  # Ensure text updates after resizing
	save_settings()  # Save changes

func center_window():
	await get_tree().process_frame  # Small delay for stability
	var center_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(center_screen - window_size / 2)

func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		get_window().set_mode(Window.MODE_FULLSCREEN)
	else:
		get_window().set_mode(Window.MODE_WINDOWED)
		await get_tree().process_frame
		center_window()
		set_resolution_text()  # Update label in windowed mode
	
	save_settings()

func save_settings():
	var config = ConfigFile.new()  # Instantiate ConfigFile
	config.set_value("display", "resolution", get_window().get_size())
	config.set_value("display", "fullscreen", get_window().get_mode() == Window.MODE_FULLSCREEN)
	config.save("user://settings.cfg")  # Save to user directory

func load_settings():
	var config = ConfigFile.new()  # Instantiate ConfigFile
	if config.load("user://settings.cfg") == OK:
		var saved_resolution = config.get_value("display", "resolution", Vector2i(1920, 1080))
		var fullscreen = config.get_value("display", "fullscreen", false)

		get_window().set_size(saved_resolution)
		get_window().set_mode(Window.MODE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED)
		check_box.set_pressed_no_signal(fullscreen)

func _on_back_to_menu_pressed() -> void:
	save_settings()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
