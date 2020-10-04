extends KinematicBody2D

signal grabbed_player

const SPEED = 40
const ACCELERATION = 10
const FRICTION = 10

var state = "Walking" # Walking, Pursuing, Returning

var velocity = Vector2.ZERO
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var path = get_parent()
onready var player = get_parent().get_parent().get_parent().get_node("Player")
var rng = RandomNumberGenerator.new()

func _ready():
	global_position = get_parent().global_position
	rng.randomize()
	var my_random_number = rng.randf_range(-100.0, 100.0)
	path.set_offset(path.get_offset() + (50 * my_random_number))

func _physics_process(_delta):
	var input_vector = (player.global_position - global_position)
	var movement_vector = input_vector.normalized()
	var dir
	var pos

	if state == "Walking":
		
		pos = path.global_position
		
		path.set_offset(path.get_offset() + (50 * _delta))
		
		dir = (path.global_position - pos)
		animationTree.set("parameters/Idle/blend_position", dir.normalized())
		animationTree.set("parameters/Run/blend_position",  dir.normalized())
		animationState.travel("Run")
		
		global_position = path.global_position
	elif state == "Pursuing":
		animationTree.set("parameters/Idle/blend_position", movement_vector)
		animationTree.set("parameters/Run/blend_position", movement_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(movement_vector * SPEED, ACCELERATION)
	elif state == "Returning":
		dir = (path.global_position - global_position)

		if dir == Vector2.ZERO or dir.length() <= 0.5:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			animationState.travel("Idle")
			global_position = path.global_position
			state = "Walking"
		else:
			velocity = velocity.move_toward(dir.normalized() * SPEED, ACCELERATION)
			animationTree.set("parameters/Idle/blend_position", dir.normalized())
			animationTree.set("parameters/Run/blend_position",  dir.normalized())
			animationState.travel("Run")
	velocity = move_and_slide(velocity)

func _on_Grab_body_entered(body):
	if body.is_in_group("player"): 
		print("game over buddy")
		emit_signal("grabbed_player")
		# game over
	pass # Replace with function body.


func _on_Walk_body_entered(body):
	if body.is_in_group("player"): 
#		print(body)
		state = "Pursuing"
#		player = body
	pass # Replace with function body.


func _on_Pursue_body_exited(body):
	if body.is_in_group("player"): 
#		print(body)
		state = "Returning"
	pass # Replace with function body.
