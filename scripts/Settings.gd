extends Control

@onready var music_check_button = $PanelContainer/MarginContainer2/VBoxContainer/MusicCheckButton
@onready var sfx_check_button = $PanelContainer/MarginContainer2/VBoxContainer/SFXCheckButton

func _ready() -> void:
	# Load settings
	load_settings()
	print(music_check_button.pressed)
	
	# Connect signals
	music_check_button.toggled.connect(_on_music_toggled)
	sfx_check_button.toggled.connect(_on_sfx_toggled)

func _on_music_toggled(toggled_value: bool) -> void:
	MusicManager.set_music_enabled(toggled_value)
	save_settings()

func _on_sfx_toggled(toggled_value: bool) -> void:
	SoundManager.set_sfx_enabled(toggled_value)
	save_settings()

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "music_enabled", music_check_button.button_pressed)
	config.set_value("audio", "sfx_enabled", sfx_check_button.button_pressed)
	config.save("user://settings.cfg")

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_check_button.button_pressed = config.get_value("audio", "music_enabled", true)
		sfx_check_button.button_pressed = config.get_value("audio", "sfx_enabled", true)
		MusicManager.set_music_enabled(music_check_button.button_pressed)
		SoundManager.set_sfx_enabled(sfx_check_button.button_pressed)


func _on_close_button_pressed() -> void:
	OverlayManager.pop_overlay()
