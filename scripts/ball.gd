extends RigidBody2D

# Define the merge hierarchy (Ball 1 -> Ball 2, ..., Ball 7 -> Ball 8)
var ball_merge_map = {
	"Ball 1": "Ball 2",
	"Ball 2": "Ball 3",
	"Ball 3": "Ball 4",
	"Ball 4": "Ball 5",
	"Ball 5": "Ball 6",
	"Ball 6": "Ball 7",
}

# Preload all ball scenes
var ball_scenes = {
	"Ball 1": load("res://scenes/ball.tscn"),
	"Ball 2": load("res://scenes/ball_2.tscn"),
	"Ball 3": load("res://scenes/ball_3.tscn"),
	"Ball 4": load("res://scenes/ball_4.tscn"),
	"Ball 5": load("res://scenes/ball_5.tscn"),
	"Ball 6": load("res://scenes/ball_6.tscn"),
	"Ball 7": load("res://scenes/ball_7.tscn"), # Final form, doesn't merge
}

# Define points per merge level
var score_map = {
	"Ball 1": 10,
	"Ball 2": 20,
	"Ball 3": 40,
	"Ball 4": 80,
	"Ball 5": 160,
	"Ball 6": 320,
}

@export var ball_type: String  # Set in the Inspector
var merging = false  # Prevents multiple merges

func _on_body_entered(body) -> void:
	if not (body is RigidBody2D and "ball_type" in body and body.ball_type == ball_type):
		return  # Ignore collisions with walls or different ball types

	if merging or (body.ball_type == ball_type and "merging" in body and body.merging):
		return  # Prevents multiple merges happening at once

	# Find the next ball type in the merge hierarchy
	if ball_type in ball_merge_map:
		var next_ball_type = ball_merge_map[ball_type]
		if next_ball_type in ball_scenes:
			merging = true
			body.merging = true  # Lock both balls to avoid duplicate merges

			var new_position = (position + body.position) / 2  # Midpoint for new ball

			# Defer the creation of the new ball and scoring update
			call_deferred("spawn_new_ball", next_ball_type, new_position, body)

func spawn_new_ball(next_ball_type, new_position, body):
	var new_ball = ball_scenes[next_ball_type].instantiate()
	new_ball.position = new_position
	new_ball.ball_type = next_ball_type
	get_parent().add_child(new_ball)

	# Update score
	if ball_type in score_map:
		var main_script = get_tree().get_root().get_node("Node2D")  # Adjust if needed
		if main_script.has_method("add_score"):
			main_script.add_score(score_map[ball_type])

	# Defer removal of merging balls
	body.call_deferred("queue_free")
	call_deferred("queue_free")
