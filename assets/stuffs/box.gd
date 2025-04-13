extends RigidBody2D

signal break_crate(amount: int)

var life: int = 3

func _process(delta: float) -> void:
	if life < 1:
		emit_signal("break_crate", 3)
		queue_free()

func take_hit():
	pass
