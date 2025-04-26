extends StaticBody2D

class_name Platform

func _process(delta: float) -> void:
	$AnimationPlayer.play("default")
	await $AnimationPlayer.animation_finished
