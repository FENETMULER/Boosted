extends CanvasLayer


func _on_play_button_pressed() -> void:
	SceneManager.change_scene('level')

func _on_quit_button_pressed() -> void:
	get_tree().quit()
