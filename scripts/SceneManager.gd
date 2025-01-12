extends Node

signal scene_changed(scene_name)

var main_scene: Node
var current_scene: Node
var current_track: String

var is_transitioning := false
var tracks := ['puurple', 'aurange', 'redd']


var scenes := {
	'main_menu': preload('res://scenes/MainMenu.tscn'),
	'auth_screen': preload('res://scenes/AuthScreen.tscn'),
	'track_selection_menu': preload('res://scenes/TrackSelectionMenu.tscn'),
	'puurple': preload('res://scenes/tracks/PuurpleTrack.tscn'),
	'aurange': preload('res://scenes/tracks/AurangeTrack.tscn'),
}

func _ready() -> void:
	main_scene = get_node('/root/Main')

func change_scene(scene_name: String) -> void:
	# check if the scene is a track
	if scene_name in tracks:
		current_track = scene_name
	else:
		current_track = ''

	if is_transitioning:
		return
	if not scenes.has(scene_name):
		push_error("Scene '%s' not found" % scene_name)
		return

	is_transitioning = false

	# If the above aren't true, show transitions

	if current_scene:
		current_scene.queue_free()

	# Instantiate and add new scene
	current_scene = scenes[scene_name].instantiate()

	if not scene_name == 'main_menu':
		TransitionScreen.show_transition()
		await TransitionScreen.transition_finished
	
	main_scene.add_child(current_scene)
	scene_changed.emit(scene_name)

	is_transitioning = false
