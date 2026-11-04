extends Control

func _ready() -> void:
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	
func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/intro.tscn")
