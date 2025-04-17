extends Area2D

var balls_in_area = {}  # Store each ball and its timers
@onready var blink_line = $BlinkLine  # Sprite2D that blinks
@onready var GameOver = $"../GameOver"

func _ready():
	blink_line.visible = false  # Initially hidden
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body is RigidBody2D and "ball_type" in body and not balls_in_area.has(body):
		# Grace period timer (2 seconds)
		var grace_timer = Timer.new()
		grace_timer.wait_time = 2.0
		grace_timer.one_shot = true
		add_child(grace_timer)
		grace_timer.connect("timeout", Callable(self, "_start_warning_timer").bind(body))
		grace_timer.start()

		balls_in_area[body] = {
			"grace": grace_timer,
			"warning": null,
			"tween": null
		}

func _start_warning_timer(body):
	if not balls_in_area.has(body):
		return

	# Start warning timer (5 seconds)
	var warning_timer = Timer.new()
	warning_timer.wait_time = 5.0
	warning_timer.one_shot = true
	add_child(warning_timer)
	warning_timer.connect("timeout", Callable(self, "_on_timeout").bind(body))
	warning_timer.start()

	# Start blinking
	blink_line.visible = true
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(blink_line, "modulate:a", 0.0, 0.3)
	tween.tween_property(blink_line, "modulate:a", 1.0, 0.3)

	# Store them
	balls_in_area[body]["warning"] = warning_timer
	balls_in_area[body]["tween"] = tween

func _on_body_exited(body):
	if balls_in_area.has(body):
		# Clean up all timers and tweens
		if balls_in_area[body]["grace"]:
			balls_in_area[body]["grace"].queue_free()
		if balls_in_area[body]["warning"]:
			balls_in_area[body]["warning"].queue_free()
		if balls_in_area[body]["tween"]:
			balls_in_area[body]["tween"].kill()

		balls_in_area.erase(body)

	# Hide the blink line if no balls are left in the area
	if balls_in_area.is_empty():
		blink_line.visible = false
		blink_line.modulate.a = 1.0  # Reset alpha

func _on_timeout(ball):
	if balls_in_area.has(ball):
		GameOver.play()
		print("❌ Game Over! Ball stayed too long.")
		GameState.is_game_over = true
		# Get references
		var main_node = get_node("/root/Node2D")  # Adjust this path if your Main is named differently
		var game_over_screen = get_node("/root/Node2D/CanvasLayer2/GameOver")

		game_over_screen.set_game_over()

		# Pause the game
		get_tree().paused = true

