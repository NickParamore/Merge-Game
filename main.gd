extends Node2D

var ball = preload("res://scenes/ball.tscn")
var ball2 = preload("res://scenes/ball_2.tscn")
var ball3 = preload("res://scenes/ball_3.tscn")
var ball4 = preload("res://scenes/ball_4.tscn")
var ball5 = preload("res://scenes/ball_5.tscn")
var ball6 = preload("res://scenes/ball_6.tscn")
var ball7 = preload("res://scenes/ball_7.tscn")
var rng = RandomNumberGenerator.new()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Left Click"):
		inst(get_global_mouse_position())

func inst(pos):
	var ballType
	var number = rng.randi_range(0,4)
	if number == 0:
		ballType = ball
	elif number == 1:
		ballType = ball2
	elif number == 2:
		ballType = ball3
	elif number == 3:
		ballType = ball4
	elif number == 4:
		ballType = ball5
	elif number == 5:
		ballType = ball6
	elif number == 6:
		ballType = ball7
		
	
	var instance = ballType.instantiate()
	instance.position = pos
	add_child(instance)
	
func ballPreview():
	var nextBall = RigidBody2D
	

