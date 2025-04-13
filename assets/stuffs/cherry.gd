extends AnimatedSprite2D

signal get_cherry(amount: int)

func _physics_process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("get_cherry", 1)
		queue_free()
