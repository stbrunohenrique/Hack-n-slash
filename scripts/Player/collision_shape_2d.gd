extends CollisionShape2D

@export var facing_right_position: Vector2
@export var facing_left_position: Vector2


func _on_player_facing_direction_changed(facing_right: bool) -> void:
	if facing_right:
		position = facing_right_position
	elif !facing_right:
		position = facing_left_position
