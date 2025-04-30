extends CharacterBody2D

class_name GroundEnemy

const speed = 1100
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
@onready var rayR = $RightRay
@onready var anim = $AnimatedSprite2D

signal dealing_damage(damage)

func _ready():
	dir = choose([Vector2.LEFT, Vector2.RIGHT])

func _process(delta):
	handlingAnimation()

func _physics_process(delta: float) -> void:
	move(delta)
	move_and_slide()
	gravityHandling(delta)
	chase(delta)
	
	if rayL.is_colliding():
		dir = Vector2.RIGHT
		
	elif rayR.is_colliding():
		dir = Vector2.LEFT
		

func handlingAnimation():
	if dead:
		anim.play("dead")
	elif takingDamage:
		anim.play("hurt")
	elif dealingDamage:
		anim.play("attack")
	elif abs(velocity.x) > 0:
		anim.play("walk")
	else:
		anim.play("idle")

	if dealingDamage or takingDamage or dead:
		anim.flip_h = targetPos.x < global_position.x
	else:
		anim.flip_h = velocity.x < 0


	

func move(delta):
	if !dead:
		if !isChasing and !dealingDamage:
			velocity = dir * speed * delta
		isRoaming = true
	elif dead:
		velocity.x = 0

func gravityHandling(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func dealdamage():
	if not dealingDamage:
		dealingDamage = true
		$AttackTimer.start()
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
	dealingDamage = false
	if isChasing and !dead and !takingDamage:
		emit_signal("dealing_damage", damage)
		dealdamage()  # Reinicia o ataque
	
	
func _on_hit_player_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerAttack"):
		hit()
		

func hit():
	if health > 0:
		takingDamage = true
		$HitTimer.start()
		health -= 1
	else:
		death()

func death():
	dead = true
	$DeadTimer.start()


func _on_dead_timer_timeout() -> void:
	dead = false
	queue_free()

func _on_hit_timer_timeout() -> void:
	takingDamage = false
