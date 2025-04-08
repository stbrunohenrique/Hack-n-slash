extends Node2D

@onready var links = $Line2D
var direction := Vector2.ZERO
var tip := Vector2.ZERO
var playerPos := Vector2.ZERO

const SPEED = 50

var flying = false
var hooked = false

func shoot(dir: Vector2):
	direction = dir.normalized()
	flying = true
	tip = self.global_position

func release():
	flying = false
	hooked = false
	
func _process(delta: float) -> void:
	self.visible = flying or hooked
	if !self.visible:
		return
	var tipLoc = to_local(tip)
	$Tip.rotation = self.position.angle_to_point(tipLoc) - deg_to_rad(90)
	links.set_point_position(0, Vector2.ZERO)
	links.set_point_position(1, tipLoc)

func _physics_process(delta: float) -> void:
	$Tip.global_position = tip
	if flying:
		if $Tip.move_and_collide(direction * SPEED):
			hooked = true
			flying = false
		tip = $Tip.global_position

func _on_player_current_position(pos: Vector2) -> void:
	playerPos = pos
