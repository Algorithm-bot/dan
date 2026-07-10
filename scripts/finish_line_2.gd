extends Area2D

# We export this so you can easily change the destination in the editor!
@export var next_level_path = "res://scenes/scene3.tscn"

func _on_body_entered(body):
	# Check if the thing crossing the finish line is the Player
	if body.is_in_group("Player"):
		
		# Teleport them to the next level!
		get_tree().change_scene_to_file(next_level_path)
