extends Area2D

@export var heal_amount = 30

# Grab references to the nodes we need to manipulate
@onready var bite_sound = $AudioStreamPlayer2D
@onready var sprite = $Sprite2D # Change this if your sprite node has a different name
@onready var collision_shape = $CollisionShape2D # Change this if needed

func _on_body_entered(body):
	# 1. Did the Player touch me?
	if body.is_in_group("Player"):
		
		# 2. Does the player have the ability to heal?
		if body.has_method("heal"):
			body.heal(heal_amount)
			
			# 3. Hide the food so it looks like it was eaten instantly
			sprite.hide()
			
			# 4. Turn off the collision so the player can't keep triggering it
			# We use set_deferred because Godot gets mad if you disable physics during a physics calculation
			collision_shape.set_deferred("disabled", true)
			
			# 5. Play the crunch!
			bite_sound.play()
			
			# 6. Wait for the sound clip to finish completely
			await bite_sound.finished
			
			# 7. Now it is safe to completely destroy the node
			queue_free()
