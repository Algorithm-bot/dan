extends Node2D

func _ready():
	# Make sure the game is unpaused if coming from the comic scene
	get_tree().paused = false
	
	# Tell the global manager to switch to the default level track
	BackgroundMusic.play_track("default")
