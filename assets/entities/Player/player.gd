extends CharacterBody2D
class_name Player

@export_category("Movement Properties")
@export_group("Horizontal Movement")
## Velocidade máxima que o jogador pode atingir
@export_range(100, 1000, 10, "suffix:ms") var maxSpeed = 400.0
## Quanto tempo leva até atingir a velocidade máxima
@export_range(0, 1, 0.1, "suffix:s") var timeToReachMaxSpeed = 0.3
## Quanto tempo leva até atingir a velocidade zero
@export_range(0, 1, 0.05, "suffix:s") var timeToReachZeroSpeed = 0.8

@export_group("Jump Handling")
## Força gravitacional
@export_range(0, 100, 5) var gravityScale = 20.0
## Máxima velocidade que o jogador pode atingir caindo
@export_range(200, 1000, 10) var maxFallSpeed = 500.0
## Força do pulo do jogador
@export_range(0, 100, 10, "suffix:kg") var jumpStrength = 30.0
## Walljump
@export_subgroup("Walljump")
@export_range(0, 400, 10, "suffix:kg") var wallJumpPushback = 100.0
@export_range(0, 1, 0.05, "suffix:s") var inputPause = 0.05
@export_range(0, 1000, 10, "suffix:kg") var wallKick = 400.0
## Buffer do pulo
@export_subgroup("Buffering")
## Intervalo de tempo 
@export_range(0, 20, 0.5, "suffix:ms") var jumpBufferTime = 12.0
@export_range(0, 20, 0.5, "suffix:ms") var coyoteTime = 15.0

@export_category("Animations")
@export_group("Basic")
@export var anim: AnimatedSprite2D
@export var col: CollisionShape2D

@export_category("Extras")
@export var canHook: bool

var mousePos: Vector2

#INFO Player stats
var cherryCount: int = 0
var maxHP: int = 3
var hp: int = 3
var lifeCount: int = 3


#INFO Its all mine, don't touch
var appliedGravity: float
var isGravityActive: bool = true
var jumpBufferTimer: float = 0
var coyoteTimer: float = 0

var acceleration: float
var desacceleration: float
var maxSpeedLock: float

var jumps: int = 1
var jumpCount: int
var jumpWasPressed: bool = false

var animScaleLock: Vector2
var colScaleLock: Vector2

var chainVelocity = Vector2.ZERO


#INFO Estava em ação
var wasRunning: bool = false
var wasMoveL: bool = false
var wasMoveR: bool = true
var wasWallJumping: bool = false
var wasHooking: bool = false
var facingRight: bool = true
var isHooked: bool = false
var isAttacking: bool = false
var comboRequested: bool = false


#INFO Pode fazer algo
var canMove: bool = true
var canWallSlide: bool = false


#INFO Input
var leftHold
var leftTap
var rightHold
var rightTap
var jumpTap
var jumpRelease
var runHold
var runRelease
var hookTap
var hookRelease
var attackTap


#INFO Signals
signal facing_direction_changed(facing_right: bool)
signal max_velocity_reached(wasReached: bool)
signal current_position(pos: Vector2)
signal hit


func hook_shot():
	if canHook:
		if hookTap:
			if facingRight:
				$Chain.shoot(mousePos)
				isHooked = true
			else:
				$Chain.shoot(mousePos)
				isHooked = true
		elif hookRelease:
			$Chain.release()
			isHooked = false

func _ready() -> void:
	_updateData()

func _updateData() -> void:
	acceleration = maxSpeed/timeToReachMaxSpeed
	desacceleration = -maxSpeed*timeToReachZeroSpeed
	
	maxSpeedLock = maxSpeed
	jumpCount = jumps
	jumpStrength = jumpStrength * gravityScale
	
	animScaleLock.x = anim.scale.x

func _process(delta: float) -> void:
	if attackTap and !isAttacking:
		handlingAttack()
	#INFO Handling animation scale
	if velocity.x > 0:
		anim.scale.x = animScaleLock.x
		emit_signal("facing_direction_changed", true)
		facingRight = true
	elif velocity.x < 0:
		anim.scale.x = animScaleLock.x * -1
		emit_signal("facing_direction_changed", false)
		facingRight = false
	
		#INFO Handling animations - run
	if !isAttacking:
		if abs(velocity.x) > 20 and is_on_floor():
			if abs(velocity.x) < (maxSpeedLock):
				anim.play("walk")
			else:
				anim.play("run")
		elif abs(velocity.x) < 15 and is_on_floor():
			anim.play("idle")
	
		#INFO Handling animations - jump
		if velocity.y < 0:
			anim.play("jump")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if isAttacking:
			comboRequested = true

func _physics_process(delta: float) -> void:
	player_movement(delta)
	hook_shot()
	emit_signal("current_position", global_position)
	respawn()

func respawn():
	if position.x < 254:
		input_pause(1)
		await get_tree().create_timer(1)
		position = $"../Level/Marker2D".position

func player_movement(delta):
	#INFO Get player input
	leftHold = Input.is_action_pressed("left")
	leftTap = Input.is_action_just_pressed("left")
	rightHold = Input.is_action_pressed("right")
	rightTap = Input.is_action_just_pressed("right")
	jumpTap = Input.is_action_just_pressed("jump")
	jumpRelease = Input.is_action_just_released("jump")
	runHold = Input.is_action_pressed("run")
	runRelease = Input.is_action_just_released("run")
	hookTap = Input.is_action_just_pressed("hook")
	hookRelease = Input.is_action_just_released("hook")
	attackTap = Input.is_action_just_pressed("attack")
	
	#INFO Jump and gravity
	jump_handling()
	wall_jump(delta)
	wall_sliding(delta)

	#INFO Horizontal movement
	horizontal_movement(delta)
	move_and_slide()
	
	#INFO Hook
	hookPhysics(delta)
	if isHooked:
		maxSpeed = maxSpeedLock

	#INFO Running handling
	if !runHold and is_on_floor() or is_on_wall():
		maxSpeed = maxSpeedLock / 2
		emit_signal("max_velocity_reached", false)

	elif is_on_floor():
		wasRunning = true
		maxSpeed = lerpf(maxSpeed, maxSpeedLock, 0.7)
		emit_signal("max_velocity_reached", true)
		if runRelease:
			wasRunning = false

	if runRelease and !is_on_floor():
		wasRunning = false
	
	if !is_on_floor() and !is_on_wall() and wasWallJumping and wasHooking:
		maxSpeed = maxSpeedLock
		emit_signal("max_velocity_reached", true)

func jump():
	if jumpCount > 0:
		velocity.y -= jumpStrength
		jumpCount -= 1

func jump_handling():
	if is_on_floor():
		coyoteTimer = coyoteTime
		jumpCount = jumps
		wasHooking = false
	if not is_on_floor():
		if coyoteTimer > 0:
			coyoteTimer -= 1

	if velocity.y > 0:
		appliedGravity = gravityScale * 1.3
	else:
		appliedGravity = gravityScale

	if isGravityActive:
		if velocity.y < maxFallSpeed:
			if coyoteTimer > 0:
				velocity.y += appliedGravity / 2
			else:
				velocity.y += appliedGravity
		elif velocity.y > maxFallSpeed:
			velocity.y = maxFallSpeed

	if jumpRelease and velocity.y < 0:
		velocity.y = velocity.y / 2

	if jumpTap and jumpCount < 1:
		jumpBufferTimer = jumpBufferTime
	elif jumpTap and jumpCount > 0:
		jump()

	if jumpBufferTimer > 0:
		jumpBufferTimer -= 1

	if jumpBufferTimer > 0 and coyoteTimer > 0:
		jump()
		jumpBufferTimer = 0
		coyoteTimer = 0

	if velocity.y < -450:
		velocity.y = -450
	elif velocity.y > 600:
		velocity.y = 600

func wall_jump(delta):
	if !is_on_wall(): return
	if is_on_floor(): return
	var wall_normal = get_wall_normal()
	wasWallJumping = true
	
	if !wasMoveR and jumpTap:
		velocity.x = 1000
		velocity.y = -jumpStrength
	if wasMoveR and jumpTap:
		velocity.x = -1000
		velocity.y = -jumpStrength
	if inputPause != 0 and jumpTap:
		canMove = false
		input_pause(inputPause)
	wasWallJumping = false

func horizontal_movement(delta):
	if rightHold and leftHold and canMove:
		velocity.x = lerpf(velocity.x, 0.0, timeToReachZeroSpeed)
		wasMoveR = true
		wasMoveL = false
	elif rightHold and canMove:
		wasMoveR = true
		wasMoveL = false
		if velocity.x > maxSpeed:
			velocity.x = maxSpeed 
		else:
			velocity.x += acceleration * delta
	elif leftHold and canMove:
		wasMoveR = false
		wasMoveL = true
		if velocity.x < -maxSpeed:
			velocity.x = -maxSpeed
		else:
			velocity.x += -acceleration * delta
	else:
		velocity.x = lerp(velocity.x, 0.0, timeToReachZeroSpeed)
	velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed)
	
	if velocity.x > 0:
		wasMoveR = true
	elif velocity.x < 0:
		wasMoveR = false

func input_pause(time):
	await get_tree().create_timer(time).timeout
	canMove = true

func wall_sliding(delta):
	if !is_on_wall(): return
	if !is_on_floor():
		if rightHold or leftHold:
			canWallSlide = true
		else:
			canWallSlide = false
	else:
		canWallSlide = false
		
	if canWallSlide:
		velocity.y += (60*delta)
		velocity.y = min(velocity.y, 60)

func hookPhysics(delta):
	if $Chain.hooked:
		wasHooking = true
		chainVelocity = to_local($Chain.tip).normalized() * 40
		if chainVelocity.y > 0:
			chainVelocity.y *= 0.2
		if sign(chainVelocity.x) == sign(velocity.x):
			chainVelocity.x *= 0.95
		else:
			chainVelocity.x *= 0.75
	else:
		chainVelocity = Vector2.ZERO
	if $Chain.hooked:
		velocity += chainVelocity

func _on_camera_2d_send_mouse_pos(pos: Vector2) -> void:
	mousePos = pos

func _on_cherry_get_cherry(amount: int) -> void:
	cherryCount += amount

func _on_box_break_crate(amount: int) -> void:
	cherryCount += amount

func hitbox_control():
	if facingRight:
		$hitbox/Right.disabled = false
		$hitbox/Left.disabled = true
	elif !facingRight:
		$hitbox/Right.disabled = true
		$hitbox/Left.disabled = false

func handlingAttack():
	$Timers/attackcombo.start(2)
	isAttacking = true
	comboRequested = false
	
	#INFO Ataca parado
	if abs(velocity.x) < 50:
		$AnimatedSprite2D.play("attack1")
		await $AnimatedSprite2D.animation_finished
		if comboRequested and $Timers/attackcombo.time_left > 0:
			$AnimatedSprite2D.play("attack2")
			await $AnimatedSprite2D.animation_finished

	#INFO Ataca andando
	else:
		$AnimatedSprite2D.play("attackwalk")
		await $AnimatedSprite2D.animation_finished
		if comboRequested and $Timers/attackcombo.time_left > 0:
			$AnimatedSprite2D.play("attack2")
			await $AnimatedSprite2D.animation_finished

	isAttacking = false
