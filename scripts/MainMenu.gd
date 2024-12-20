extends CanvasLayer


func _on_play_button_pressed() -> void:
	SceneManager.change_scene('track_selection_menu')

func _on_quit_button_pressed() -> void:
	get_tree().quit()
