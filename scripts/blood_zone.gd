extends Area2D

# Grab a reference to our new wind audio node
@onready var wind_sound = $WindSound 

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.is_on_blood = true
		
		# 1. Mute the main background music
		BackgroundMusic.volume_db = -80.0
		
		# 2. Start the spooky wind!
		wind_sound.play()

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.is_on_blood = false
		
		# 1. Return the main background music to normal volume
		BackgroundMusic.volume_db = 0.0
		
		# 2. Stop the wind!
		wind_sound.stop()
