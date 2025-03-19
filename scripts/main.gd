extends Node2D

var ball_data = [
	{"texture": preload("res://assets/ball.png"), "scene": preload("res://scenes/ball.tscn")},
	{"texture": preload("res://assets/ball_2.png"), "scene": preload("res://scenes/ball_2.tscn")},
	{"texture": preload("res://assets/ball_3.png"), "scene": preload("res://scenes/ball_3.tscn")},
	{"texture": preload("res://assets/ball_4.png"), "scene": preload("res://scenes/ball_4.tscn")},
	{"texture": preload("res://assets/ball_5.png"), "scene": preload("res://scenes/ball_5.tscn")},
	{"texture": preload("res://assets/ball_6.png"), "scene": preload("res://scenes/ball_6.tscn")},
	{"texture": preload("res://assets/ball_7.png"), "scene": preload("res://scenes/ball_7.tscn")}
]

var score = 0  # Keeps track of the player score
@onready var score_label = $Score  # Reference to the Label node
	
var rng = RandomNumberGenerator.new()
var next_ball_index = 0

@onready var preview_sprite: Sprite2D = $PreviewSprite  # Make sure this exists in your scene

func _ready():
	generate_next_ball_preview()
	score_label.text = "Score: 0"

func add_score(points):
	score += points
	score_label.text = "Score: " + str(score)  # Update label text

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Left Click"):
		spawn_ball(get_global_mouse_position())

func spawn_ball(pos: Vector2):
	var ball_instance = ball_data[next_ball_index]["scene"].instantiate()
	ball_instance.position = pos
	add_child(ball_instance)

	# Generate new preview
	generate_next_ball_preview()

func generate_next_ball_preview():
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

