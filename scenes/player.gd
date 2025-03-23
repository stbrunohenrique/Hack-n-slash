extends CharacterBody2D


const SPEED = 300
const ACCEL = 150
const JUMP_VELOCITY = -400
@export var jumpCount : int = 0
var jumpMax = 2


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor():
		jumpCount = 0
	if Input.is_action_just_pressed("jump") and (jumpCount < jumpMax):
		velocity.y = JUMP_VELOCITY
		jumpCount += 1

	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = 2
	else:
		velocity.x = 2
	move_and_slide()
	
