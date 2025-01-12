extends Control


func _on_play_button_pressed() -> void:
	get_tree().paused = false
	OverlayManager.pop_overlay()


func _on_main_menu_button_pressed() -> void:
	_change_scene_and_pop_overlay('main_menu')


func _on_tracks_button_pressed() -> void:
	_change_scene_and_pop_overlay('track_selection_menu')

func _change_scene_and_pop_overlay(scene_name: String) -> void:
	get_tree().paused = false
	SceneManager.change_scene(scene_name)
	OverlayManager.pop_overlay()


func _on_leaderboard_button_pressed() -> void:
	var leaderboard_scene = preload('res://scenes/ui/Leaderboard.tscn').instantiate()
	leaderboard_scene.track_name = SceneManager.current_track
	OverlayManager.push_overlay_node(leaderboard_scene)
	print(leaderboard_scene.track_name)
