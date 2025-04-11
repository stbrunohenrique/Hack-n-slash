extends Marker2D

signal mouse_position(pos: Vector2)

	
func _process(delta: float) -> void:
	position = get_global_mouse_position()
	emit_signal("mouse_position", self.position)
