extends CanvasLayer

@onready var label: Label = $Control/Label
@onready var player: CharacterBody2D = $"../Player"

func _process(delta: float) -> void:
	label.text = "x" + str(player.cherryCount)
