extends Node2D

func _ready() -> void:
	if Engine.is_editor_hint():
		#I'm in the editor
		$ParallaxBG.visible = false
