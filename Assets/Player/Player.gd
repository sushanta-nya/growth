extends KinematicBody2D

enum{
	MOVE,
	ATTACK
}

var state = MOVE

#score system
var score = 0 setget set_score

func set_score(value):
	score += value
	$Score.set_text("score "+ str(score))


# The player moves with WASD keys
# var to store velocity
var velocity = Vector2.ZERO

const ACCELARATION = 400  
const MAX_SPEED = 100
const FRICTION = 800

onready var animation = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

func _ready():
	animation_tree.active = true

func _physics_process(delta):
	
	match state:
		MOVE:
			move_State(delta)
			
		ATTACK:
			attack_State(delta)



func move_State(delta):
		
	# this var willl contain the key input
	var input_vector = Vector2.ZERO
	
	# here we will check key-input and if the key is pressed the value will be 1 otherwise 0
	input_vector.x = Input.get_action_strength("Move_right") - Input.get_action_strength("Move_left")
	input_vector.y = Input.get_action_strength("Move_down") - Input.get_action_strength("Move_up")
	
	#normalizing the digonal speed to match the speed in the h and v direction
	input_vector = input_vector.normalized()
	
	# checking if the key is pressed or not and setting the velocity
	if input_vector != Vector2.ZERO :
		animation_tree.set("parameters/idle/blend_position", input_vector)
		animation_tree.set("parameters/run/blend_position", input_vector)
		animation_tree.set("parameters/fireball/blend_position", input_vector)
		animation_state.travel("run")
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED , ACCELARATION * delta)
	else:
		animation_state.travel("idle")
		
		# move the velocity toward zero with fixed rate
		velocity = velocity.move_toward(Vector2.ZERO , FRICTION * delta)
		
	#inbuild godot function to move the kinematic body along the provided vector
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
	
func attack_State(delta):
	animation_state.travel("fireball")

func attack_animation_finished():
	state = MOVE
