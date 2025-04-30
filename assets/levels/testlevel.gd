extends Node2D

var isDamaging: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		#I'm in the editor
		$ParallaxBG.visible = false

func _physics_process(delta: float) -> void:
	if isDamaging:
		pass

func _on__body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		isDamaging = true


func _on__body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		isDamaging = false
