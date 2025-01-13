extends Node

@onready var music_player = AudioStreamPlayer.new()
var current_music_track: String = ""
var music_enabled: bool

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	add_child(music_player)
	
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_enabled = config.get_value("audio", "music_enabled", true)
		set_music_enabled(music_enabled)

func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if music_enabled:
		resume_music()
	else:
		pause_music()

func play_music(audio_path: String):
	if (current_music_track == audio_path and music_player.playing):
		return
		
	current_music_track = audio_path
	var stream = load(audio_path)
	
	music_player.stream = stream
	music_player.play() # Not checking music_enabled prior to playing so that music starts playing immediately after being enabled
	if not music_enabled:
		pause_music()
func stop_music():
	music_player.stop()
	
func pause_music():
	music_player.stream_paused = true
	
func resume_music():
	music_player.stream_paused = false
