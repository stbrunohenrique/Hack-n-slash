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

var targetPos: Vector2

@onready var zone = $Zone
@onready var rayL = $LeftRay
@onready var rayR = $LeftRay
@onready var anim = $AnimatedSprite2D

signal dealing_damage(damage)


func _process(delta):
	handlingAnimation()

func _physics_process(delta: float) -> void:
	move(delta)
	move_and_slide()
	gravityHandling(delta)
	chase(delta)

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
	$AttackTimer.start()
	dealingDamage = false
	velocity.x = 0

func chase(delta):
	if isChasing:
		pass

func _on_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		isChasing = true
		targetPos = body.position
		dealdamage()

func _on_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		isChasing = false

func _on_attack_timer_timeout() -> void:
	emit_signal("dealing_damage", damage)
