extends Area2D
class_name Flag

@onready var anim = $Animation

var firstTime: bool = true


func _physics_process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and firstTime:
		firstTime = false
		anim.offset.x = 8.5
		anim.play("flagout")
		await anim.animation_finished
		anim.play("flagidle")
		
