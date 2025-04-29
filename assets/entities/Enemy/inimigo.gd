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

@onready var anim = $AnimatedSprite2D


func _process(delta):
	gravityHandling(delta)
	move(delta)
	handlingAnimation()
	move_and_slide()

func handlingAnimation():
	if abs(velocity.x) > 0:
		anim.play("walk")
	elif abs(velocity.x) < 0.2:
		anim.play("idle")
	if takingDamage:
		anim.play("hurt")
	if velocity.x > 0:
		anim.flip_h = false
	else:
		anim.flip_h = true
	if dealingDamage:
		anim.play("attack")

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

func dealdamage():
	dealingDamage = true
	#PlayerVariables.hp -= damage
	dealingDamage = false
	velocity.x = 0
	
