extends Node

var sounds = {
    "button_sfx_1": preload("res://assets/audio/sfx/button/button_sfx_1.wav"),
    "button_sfx_2": preload("res://assets/audio/sfx/button/button_sfx_2.wav"),
    "button_sfx_3": preload("res://assets/audio/sfx/button/button_sfx_3.wav"),
	
}

func play_button_sfx():
	var audio = AudioStreamPlayer.new()
	var sound_name = sounds.keys()[randi_range(0, sounds.size() - 1)]
	audio.stream = sounds[sound_name]
	add_child(audio)
	audio.play()
	audio.finished.connect(audio.queue_free)
