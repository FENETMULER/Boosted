extends Node

signal scene_changed(scene_name)

var main_scene: Node
var current_scene: Node

var is_transitioning := false


var scenes := {
    "main_menu": preload("res://scenes/MainMenu.tscn"),
    "level": preload("res://scenes/Level1.tscn")
}

func _ready() -> void:
    main_scene = get_node('/root/Main')

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
    current_scene = scenes[scene_name].instantiate()

    TransitionScreen.show_transition()
    await TransitionScreen.transition_finished
    
    main_scene.add_child(current_scene)
    scene_changed.emit(scene_name)

    is_transitioning = false

func play_transition_animation() -> void:
    # Transition logic goes here
    pass