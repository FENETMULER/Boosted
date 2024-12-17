extends Control

@onready var tracks_wrapper: HBoxContainer = %TracksWrapper
@onready var scroll_container: ScrollContainer = %ScrollContainer

var target_scroll = 0

func _on_next_track_button_pressed() -> void:
	scroll_container.scroll_horizontal += _get_distance_to_scroll()

func _on_previous_track_button_pressed() -> void:
	scroll_container.scroll_horizontal -= _get_distance_to_scroll()
	

func _get_distance_to_scroll():
	var item_size = tracks_wrapper.get_children()[1].size.x
	var separation = tracks_wrapper.get_theme_constant('separation')
	return item_size + separation
