extends Node2D

# Only define the first 5 balls
var ball_data = [
	{"texture": preload("res://assets/ball.png"), "scene": preload("res://scenes/ball.tscn")},
	{"texture": preload("res://assets/ball_2.png"), "scene": preload("res://scenes/ball_2.tscn")},
	{"texture": preload("res://assets/ball_3.png"), "scene": preload("res://scenes/ball_3.tscn")},
	{"texture": preload("res://assets/ball_4.png"), "scene": preload("res://scenes/ball_4.tscn")},
	{"texture": preload("res://assets/ball_5.png"), "scene": preload("res://scenes/ball_5.tscn")}
]

const SAVEFILE = "user://savefile.save"

var score = 0 
var best_score = 0
@onready var score_label = $Score
@onready var best_score_label = $BestScore
var rng = RandomNumberGenerator.new()
var next_ball_index = 0

@onready var preview_sprite: Sprite2D = $PreviewSprite  # Make sure this exists in your scene
var spawn_allowed = false  # Flag to check if the mouse is in the valid spawn area

# Define the spawn area (adjust based on your box's position)
var spawn_area_top = 50   # Y position where spawning is allowed (top of the box)
var spawn_area_bottom = 1000  # Fixed Y position where the ball will be dropped (bottom of the spawnable space)
var spawn_area_left = 400  # Left side of the spawn area (adjust as needed)
var spawn_area_right = 700  # Right side of the spawn area (adjust as needed)

func _ready():
	generate_next_ball_preview()
	score_label.text = "Score: 0"
	load_score()
	
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
	score += points
	score_label.text = "Score: " + str(score)
	
	# Update best score if the new score is higher
	if score > best_score:
		best_score = score
		best_score_label.text = "Best Score: " + str(best_score)
		save_score()

func _process(delta):
	var mouse_pos = get_global_mouse_position()

	# Restrict preview movement to the spawn area (top of the box)
	if mouse_pos.y >= spawn_area_top and mouse_pos.y <= spawn_area_bottom and mouse_pos.x >= spawn_area_left and mouse_pos.x <= spawn_area_right:
		spawn_allowed = true
		preview_sprite.position = Vector2(mouse_pos.x, spawn_area_top)  # Keep at drop height
		preview_sprite.show()
	else:
		spawn_allowed = false
		preview_sprite.hide()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if spawn_allowed:
			spawn_ball(preview_sprite.position)

func spawn_ball(pos: Vector2):
	var ball_instance = ball_data[next_ball_index]["scene"].instantiate()
	ball_instance.position = pos
	add_child(ball_instance)

	# Generate new preview
	generate_next_ball_preview()

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
