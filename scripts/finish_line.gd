extends Area2D

@export var next_level_path = "res://scenes/scene2.tscn"

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# Change the scene instantly using Godot's built-in SceneTree function
		get_tree().change_scene_to_file(next_level_path)
