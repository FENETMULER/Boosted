extends Node

signal scene_changed(scene_name)

var current_scene = null
var is_transitioning := false


var scenes := {
    "main_menu": preload("res://scenes/MainMenu.tscn"),
    "level": preload("res://scenes/Level1.tscn")
}

func _ready() -> void:
    current_scene = get_tree().current_scene

func change_scene(scene_name: String) -> void:
    if is_transitioning:
        return
    if not scenes.has(scene_name):
        push_error("Scene $s not found" % scene_name)
        return
    
    is_transitioning = false

    # If the above aren't true, show transitions

    if current_scene:
        current_scene.queue_free()

    # Instantiate and add new scene
    var new_scene = scenes[scene_name].instantiate()
    get_tree().root.call_deferred('add_child', new_scene)
    current_scene = new_scene
    emit_signal('scene_changed', scene_name)

    is_transitioning = false

func play_transition_animation() -> void:
    # Transition logic goes here
    pass