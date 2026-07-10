extends AudioStreamPlayer

# 1. Add your Level 2 preload here at the top
const DEFAULT_BGM = preload("res://music/misc/bgMusic.ogg") 
const LEVEL_2_BGM = preload("res://music/warrior/level2.mp3")
const LEVEL_3_BGM = preload("res://music/shaman/shaman.mp3")
const LEVEL_4_BGM = preload("res://music/goblin/rain.mp3") 
const MENU_BGM = preload("res://music/misc/menu.mp3")
const COMIC_BGM = preload("res://music/misc/comic.mp3")

func play_track(track_name: String):
	var track_to_play: AudioStream = null
	
	# 2. Add an 'elif' check for your new track
	if track_name == "default":
		track_to_play = DEFAULT_BGM
	elif track_name == "level2":             # <-- Added this check
		track_to_play = LEVEL_2_BGM
	elif track_name =="level3":
		track_to_play=LEVEL_3_BGM
	elif track_name =="level4":
		track_to_play=LEVEL_4_BGM          # <-- Added this assignment
	elif track_name == "menu":
		track_to_play = MENU_BGM
	elif track_name == "comic":
		track_to_play = COMIC_BGM
		
	if stream == track_to_play and playing:
		return 
		
	stream = track_to_play
	play()
