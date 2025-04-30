extends Node2D



func _ready() -> void:
	if Engine.is_editor_hint():
		#I'm in the editor
		$ParallaxBG.visible = false

func _physics_process(delta: float) -> void:
	pass

func _on__body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$Player.hp -= 1
