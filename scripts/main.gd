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
@onready var preview_sprite: Sprite2D = $PreviewSprite
@onready var next_preview_sprite: Sprite2D = $NextBall/NextBallSprite
@onready var spawn_area: Area2D = $ClickableArea
@onready var clouds: Sprite2D = $Clouds

var current_ball_index = 0
var next_ball_index = 0
var rng = RandomNumberGenerator.new()

var spawn_area_left: float
var spawn_area_right: float
var spawn_allowed = false
var fixed_spawn_y = 250
var last_valid_position = Vector2()

var bob_speed = 1.5
var bob_amplitude = 5.0
var original_y = 820
var time_passed = 0.0

func _ready():
	generate_next_ball_preview()
	score_label.text = "Score: 0"
	load_score()
	spawn_area.connect("mouse_entered", _on_spawn_area_entered)
	spawn_area.connect("mouse_exited", _on_spawn_area_exited)
	preview_sprite.hide()

	var spawn_area_rect = spawn_area.get_node("CollisionShape2D").shape.get_rect()
	spawn_area_left = spawn_area.global_position.x + spawn_area_rect.position.x
	spawn_area_right = spawn_area_left + spawn_area_rect.size.x

	var spawn_area_center = (spawn_area_left + spawn_area_right) / 2
	preview_sprite.position = Vector2(spawn_area_center, fixed_spawn_y)
	preview_sprite.show()

func _process(delta):
	time_passed += delta
	clouds.position.y = original_y + sin(time_passed * bob_speed) * bob_amplitude
	var mouse_pos = get_global_mouse_position()

	if spawn_allowed:
		var ball_radius = preview_sprite.texture.get_size().x * preview_sprite.scale.x / 2
		var clamped_x = clamp(mouse_pos.x, spawn_area_left + ball_radius, spawn_area_right - ball_radius)
		preview_sprite.position = Vector2(clamped_x, fixed_spawn_y)
		preview_sprite.show()
	elif last_valid_position != Vector2():
		preview_sprite.position = last_valid_position

func _on_spawn_area_entered():
	spawn_allowed = true

func _on_spawn_area_exited():
	spawn_allowed = false

func save_score():
	if best_score > 0:
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
	if score > best_score:
		best_score = score
		best_score_label.text = "Best Score: " + str(best_score)
		save_score()

var ball_spawned = false

func _input(event):
	if event is InputEventMouseButton and event.pressed and spawn_allowed:
		if ball_spawned:
			return
		var mouse_pos = get_global_mouse_position()
		$ballDrop.play()
		var ball_radius = preview_sprite.texture.get_size().x * preview_sprite.scale.x / 2
		var clamped_x = clamp(mouse_pos.x, spawn_area_left + ball_radius, spawn_area_right - ball_radius)
		var spawn_pos = Vector2(clamped_x, fixed_spawn_y)
		preview_sprite.position = spawn_pos
		spawn_ball(spawn_pos)

func spawn_ball(pos: Vector2):
	ball_spawned = true
	var ball_instance = ball_data[current_ball_index]["scene"].instantiate()
	pos.x = clamp(pos.x, spawn_area_left, spawn_area_right)
	pos.y = fixed_spawn_y
	ball_instance.position = pos
	add_child(ball_instance)
	generate_next_ball_preview()
	ball_instance.connect("ball_collided", Callable(self, "_on_ball_collided"))

func _on_ball_collided():
	ball_spawned = false

func generate_next_ball_preview():
	current_ball_index = next_ball_index
	next_ball_index = rng.randi_range(0, ball_data.size() - 1)

	var current_texture = ball_data[current_ball_index]["texture"]
	var next_texture = ball_data[next_ball_index]["texture"]
	var current_scene = ball_data[current_ball_index]["scene"]
	var next_scene = ball_data[next_ball_index]["scene"]

	if preview_sprite:
		preview_sprite.texture = current_texture
		if current_texture:
			var texture_size = current_texture.get_size()
			var temp_ball = current_scene.instantiate()
			var ball_size = temp_ball.get_node("CollisionShape2D").shape.radius * 2
			temp_ball.queue_free()
			preview_sprite.scale = Vector2(ball_size / texture_size.x, ball_size / texture_size.y)

	if next_preview_sprite:
		next_preview_sprite.texture = next_texture
		if next_texture:
			var next_size = next_texture.get_size()
			var temp_next = next_scene.instantiate()
			var ball_size_next = temp_next.get_node("CollisionShape2D").shape.radius * 2
			temp_next.queue_free()
			next_preview_sprite.scale = Vector2(ball_size_next / next_size.x, ball_size_next / next_size.y)
		else:
			print("⚠️ Warning: Next ball texture not found.")
