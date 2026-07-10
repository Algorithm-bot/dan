extends CanvasLayer

@onready var pause_menu = $PauseMenu

func _ready():
	# Make sure menu is hidden when level loads
	if pause_menu.has_method("close"):
		pause_menu.close()
	else:
		pause_menu.hide()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

func pause_game():
	get_tree().paused = true
	# Trigger Maaack's menu animation
	if pause_menu.has_method("open"):
		pause_menu.open()
	else:
		pause_menu.show()

func resume_game():
	get_tree().paused = false
	if pause_menu.has_method("close"):
		pause_menu.close()
	else:
		pause_menu.hide()

func _on_pause_menu_closed() -> void:
	pass # Replace with function body.
