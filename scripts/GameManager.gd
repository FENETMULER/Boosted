extends Node

func get_best_time(track_name: String) -> float:
	var save_data = {}
	var save_path = "user://best_scores.save"
	var file = FileAccess.open(save_path, FileAccess.READ)
	
	if file:
		var json_string = file.get_as_text()
		save_data = JSON.parse_string(json_string)
	
	if save_data.has(track_name):
		return save_data[track_name]
	else:
		return -1

func setup_sound_buttons():
	# Get all nodes in the 'UIButtons' group
	for button in get_tree().get_nodes_in_group("buttons_with_sfx"):
		# Connect the 'pressed' signal to the handler
		button.pressed.connect(SoundManager.play_button_sfx)
