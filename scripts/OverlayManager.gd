extends CanvasLayer

var overlay_stack: Array = []

var overlay_scenes: Dictionary = {
	"pause_menu": preload("res://scenes/ui/PauseMenu.tscn"),
	# "Leaderboard": preload("res://scenes/Leaderboard.tscn"),
	
}

func push_overlay(overlay_name: String):
	var overlay = overlay_scenes[overlay_name].instantiate()
	overlay_stack.append(overlay)
	add_child(overlay)
	overlay.position = Vector2(0, 0) # Adjust to your screen's center or desired position
	# overlay.process_mode = Node.PROCESS_MODE_ALWAYS

# Removes the top overlay from the stack
func pop_overlay():
	if overlay_stack.size() > 0:
		var overlay = overlay_stack.pop_back()
		overlay.queue_free()

# Clears all overlays
func clear_overlays():
	for overlay in overlay_stack:
		overlay.queue_free()
	overlay_stack.clear()
