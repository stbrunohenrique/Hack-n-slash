extends Camera2D

@export var Player: Player

var cameraZoomLock = self.zoom
var targetZoom = Vector2(2, 2)
var positionLock = self.offset
var targetPositionR = Vector2(100, 0)
var targetPositionL = Vector2(-100, 0)
var facingRight: bool = true
var neutralPositionR = Vector2(20, 0)
var neutralPositionL = Vector2(-20, 0)


func _ready():
	self.offset = neutralPositionR

func _process(delta):
	pass
	position = get_node("../Player").position
	if facingRight:
		self.offset = lerp(offset, neutralPositionR, 0.02)
	elif !facingRight:
		self.offset = lerp(offset, neutralPositionL, 0.02)


func _on_player_max_velocity_reached(wasReached: bool) -> void:
	if wasReached:
		zoom = lerp(zoom, targetZoom, 0.02)
		if facingRight:
			self.offset = lerp(offset, targetPositionR, 0.02)
		elif !facingRight:
			self.offset = lerp(offset, targetPositionL, 0.02)
	else: 
		zoom = lerp(zoom, cameraZoomLock, 0.06)
		self.offset = lerp(offset, positionLock, 0.05)


func _on_player_facing_direction_changed(facing_right: bool) -> void:
	if facing_right:
		facingRight = true
	else:
		facingRight = false
