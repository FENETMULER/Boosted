extends Node2D

func _ready() -> void:
	start_game()

func start_game() -> void:
	SceneManager.change_scene("main_menu")
