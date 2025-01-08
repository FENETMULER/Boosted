extends CanvasLayer

var overlay_stack: Array = []

var overlay_scenes: Dictionary = {
	"pause_menu": preload("res://scenes/ui/PauseMenu.tscn"),
	"leaderboard": preload("res://scenes/ui/Leaderboard.tscn"),
	
}

func push_overlay(overlay_name: String):
	var overlay = overlay_scenes[overlay_name].instantiate()
	overlay_stack.append(overlay)
	if overlay_stack.size() > 1:
		overlay.z_index = 3
	add_child(overlay)
	overlay.position = Vector2(0, 0)
	# overlay.process_mode = Node.PROCESS_MODE_ALWAYS

func push_overlay_node(overlay: Node):
	overlay_stack.append(overlay)
	if overlay_stack.size() > 1:
		overlay.z_index = 3
	add_child(overlay)
	overlay.position = Vector2(0, 0)

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
