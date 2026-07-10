extends Control

# This creates an array in the Inspector where you can drop your images
@export var comic_panels: Array[Texture2D]

# The scene to load after the comic ends (e.g., your first level)
@export var next_scene_path: String = "res://level_1.tscn" 

@onready var comic_display: TextureRect = $ComicDisplay
var current_panel_index: int = 0

func _ready():
	# Show the first panel when the scene loads
	if comic_panels.size() > 0:
		comic_display.texture = comic_panels[0]
	BackgroundMusic.play_track("comic")

func _input(event):
	# Check for a mouse click or the "ui_accept" action (Spacebar/Enter)
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		advance_comic()

func advance_comic():
	current_panel_index += 1
	
	# If there are still panels left, show the next one
	if current_panel_index < comic_panels.size():
		comic_display.texture = comic_panels[current_panel_index]
	else:
		# If we are out of panels, load the main game
		get_tree().change_scene_to_file(next_scene_path)
