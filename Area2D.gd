extends Area2D

var balls_in_area = {}  # Dictionary to track timers for each ball

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body is RigidBody2D and "ball_type" in body:
		# Start a timer for this ball
		var timer = Timer.new()
		timer.wait_time = 5.0  # 5 seconds
		timer.one_shot = true
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_timeout").bind(body))
		timer.start()
		balls_in_area[body] = timer  # Store the timer reference

func _on_body_exited(body):
	if body in balls_in_area:
		# Remove and stop the timer if the ball leaves early
		balls_in_area[body].queue_free()
		balls_in_area.erase(body)

func _on_timeout(ball):
	if ball in balls_in_area:
		print("Game Over! A ball stayed in the top area too long.")
		get_tree().reload_current_scene()  # Restart the game
