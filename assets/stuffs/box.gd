extends RigidBody2D

signal break_crate(amount: int)

var life: int = 3
var isTakingDamage: bool = false

func _process(delta: float) -> void:
	if life < 1:
		emit_signal("break_crate", 3)
		queue_free()

func take_hit():
	pass

func _on_player_hit() -> void:
	if isTakingDamage:
		life -= 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		isTakingDamage = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		isTakingDamage = false
