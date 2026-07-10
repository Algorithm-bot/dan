extends CanvasLayer

@onready var video_stream_player = $VideoStreamPlayer 

func change_scene(target_scene_path: String):
	# 1. Make sure the video is visible, then play it
	video_stream_player.show()
	video_stream_player.play()
	
	# 2. WAIT until the video finishes playing completely
	await video_stream_player.finished
	
	# 3. Swap the active level safely in the background
	get_tree().change_scene_to_file(target_scene_path)
	
	# 4. Hide the video player to instantly reveal the new level
	video_stream_player.hide()
