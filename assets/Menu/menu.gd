extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/levels/00/main.tscn")


func _on_credits_btn_pressed() -> void:
	pass # Replace with function body.


func _on_quitbtn_pressed() -> void:
	get_tree().quit()
