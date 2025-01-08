extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


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
	OverlayManager.push_overlay('leaderboard')
