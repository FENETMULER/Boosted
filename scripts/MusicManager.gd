extends Node

@onready var music_player = AudioStreamPlayer.new()
var current_track: String = ""

func _ready():
    add_child(music_player)
    
    # music_player.process_mode = Node.PROCESS_MODE_ALWAYS

func play_music(audio_path: String):
    if current_track == audio_path and music_player.playing:
        return
        
    current_track = audio_path
    var stream = load(audio_path)
    music_player.stream = stream
    music_player.play()
func stop_music():
    music_player.stop()
    
func pause_music():
    music_player.stream_paused = true
    
func resume_music():
    music_player.stream_paused = false