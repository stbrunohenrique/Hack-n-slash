extends AnimatedSprite2D

signal get_cherry(amount: int)

func _process(delta: float) -> void:
	play("default")
	await animation_finished
