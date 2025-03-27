extends Node2D

# Only define the first 5 balls
var ball_data = [
	{"texture": preload("res://assets/ball.png"), "scene": preload("res://scenes/ball.tscn")},
	{"texture": preload("res://assets/ball_2.png"), "scene": preload("res://scenes/ball_2.tscn")},
	{"texture": preload("res://assets/ball_3.png"), "scene": preload("res://scenes/ball_3.tscn")},
	{"texture": preload("res://assets/ball_4.png"), "scene": preload("res://scenes/ball_4.tscn")},
	{"texture": preload("res://assets/ball_5.png"), "scene": preload("res://scenes/ball_5.tscn")}
]

var dropSound = preload("res://assets/bubbleDrop.wav")
const SAVEFILE = "user://savefile.save"

var score = 0 
var best_score = 0
@onready var score_label = $Score
@onready var best_score_label = $BestScore
var rng = RandomNumberGenerator.new()
var next_ball_index = 0

@onready var preview_sprite: Sprite2D = $PreviewSprite  # Make sure this exists in your scene
@onready var spawn_area: Area2D = $ClickableArea  # Reference your Area2D node
var spawn_area_left: float
var spawn_area_right: float
var spawn_allowed = false  # Flag to check if the mouse is in the valid spawn area

var fixed_spawn_y = 50  # Custom spawn height

func generate_next_ball_preview():
	# Pick a random ball from the first 5
	next_ball_index = rng.randi_range(0, ball_data.size() - 1)

	var next_ball_texture = ball_data[next_ball_index]["texture"]
	var next_ball_scene = ball_data[next_ball_index]["scene"]

	if preview_sprite:
		preview_sprite.texture = next_ball_texture  # Update texture
		
		if next_ball_texture:
			# Get the texture size
			var texture_size = next_ball_texture.get_size()
			
			# Get the actual ball instance to find its correct in-game scale
			var temp_ball = next_ball_scene.instantiate()
			var ball_size = temp_ball.get_node("CollisionShape2D").shape.radius * 2  # Diameter
			temp_ball.queue_free()  # Delete temporary ball
			
			# Scale the preview sprite to match the actual in-game ball size
			preview_sprite.scale = Vector2(ball_size / texture_size.x, ball_size / texture_size.y)
		else:
			print("⚠️ Warning: Texture not found for preview ball.")
	else:
		print("⚠️ Warning: 'PreviewSprite' not found or not a Sprite2D.")


func _ready():
	#Generate the preview ball
	generate_next_ball_preview()
	score_label.text = "Score: 0"
	load_score()
	spawn_area.connect("mouse_entered", _on_spawn_area_entered)
	spawn_area.connect("mouse_exited", _on_spawn_area_exited)
	preview_sprite.hide()  # Hide preview initially

	# Get the spawnable area bounds (adjust these as needed)
	var spawn_area_rect = spawn_area.get_node("CollisionShape2D").shape.get_rect()
	spawn_area_left = spawn_area.global_position.x + spawn_area_rect.position.x
	spawn_area_right = spawn_area_left + spawn_area_rect.size.x

	# Calculate the center of the spawnable area
	var spawn_area_center = (spawn_area_left + spawn_area_right) / 2

	# Set the preview ball to the center of the spawnable area
	preview_sprite.position = Vector2(spawn_area_center, fixed_spawn_y)

	# Show the preview now
	preview_sprite.show()


func _on_spawn_area_entered():
	spawn_allowed = true

func _on_spawn_area_exited():
	spawn_allowed = false
	
func save_score():
	if best_score > 0:  # Only save if there's a valid score
		var file = FileAccess.open(SAVEFILE, FileAccess.WRITE)
		file.store_32(best_score)

func load_score():
	if FileAccess.file_exists(SAVEFILE):
		var file = FileAccess.open(SAVEFILE, FileAccess.READ)
		best_score = file.get_32()
		best_score_label.text = "Best Score: " + str(best_score)

func add_score(points):
	$ballMerge.play()
	score += points
	score_label.text = "Score: " + str(score)
	
	# Update best score if the new score is higher
	if score > best_score:
		best_score = score
		best_score_label.text = "Best Score: " + str(best_score)
		save_score()

var last_valid_position = Vector2()  # Store the last valid position

func _process(delta):
	var mouse_pos = get_global_mouse_position()

	if spawn_allowed:
		
		# Clamp the x position of the preview ball to stay within the spawnable area
		var clamped_x = clamp(mouse_pos.x, spawn_area_left, spawn_area_right)

		# Update last known valid position and move the preview
		last_valid_position = Vector2(clamped_x, fixed_spawn_y)
		preview_sprite.position = last_valid_position
		preview_sprite.show()
	elif last_valid_position != Vector2():  # Ensure it's not (0,0)
		preview_sprite.position = last_valid_position


var ball_spawned = false  # Prevents multiple spawns before collision

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if ball_spawned:
			return  # Prevent multiple spawns before collision

		var mouse_pos = get_global_mouse_position()

		# Ensure ball always spawns within the defined area
		if spawn_allowed:
			spawn_ball(preview_sprite.position)
			$ballDrop.play()
		else:
			var clamped_x = clamp(mouse_pos.x, spawn_area_left, spawn_area_right)
			var spawn_pos = Vector2(clamped_x, fixed_spawn_y)
			spawn_ball(spawn_pos)

func spawn_ball(pos: Vector2):
	ball_spawned = true  # Prevent further spawns until collision

	var ball_instance = ball_data[next_ball_index]["scene"].instantiate()
	pos.x = clamp(pos.x, spawn_area_left, spawn_area_right)
	pos.y = fixed_spawn_y  # Keep ball within the spawn area

	ball_instance.position = pos
	add_child(ball_instance)
	
	generate_next_ball_preview()
	# Connect the collision signal
	ball_instance.connect("ball_collided", Callable(self, "_on_ball_collided"))

func _on_ball_collided():
	ball_spawned = false  # Allow spawning again
