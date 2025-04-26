extends CharacterBody2D

class_name GroundEnemy

const speed = 50
var isChasing: bool

var health = 3
var maxHealth = 3
var minHealth = 0

var dead: bool = false
var takingDamage: bool = false
var damage = 1
var dealingDamage: bool = false

var dir: Vector2
const gravity = 500
var knockbackForce = 200
var isRoaming: bool = true

func _process(delta):
	gravityHandling(delta)
	move(delta)
	move_and_slide()

func move(delta):
	if !dead:
		if !isChasing:
			velocity += dir * speed * delta
		isRoaming = true
	elif dead:
		velocity.x = 0

func gravityHandling(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5, 2.0, 2.5])
	if !isChasing:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()
