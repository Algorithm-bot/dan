extends Node2D 

func _ready():
	# Make sure the game is unpaused (just in case)
	get_tree().paused = false
	
	# Tell the global manager to play the level 2 track
	BackgroundMusic.play_track("level2")
