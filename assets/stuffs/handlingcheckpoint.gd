extends Node2D

var isChecked = false


func _ready() -> void:
	isChecked = false

func _on_player_death() -> void:
	if $Area2D.firstTime == false:
		$"../../Marker2D".global_position = global_position
