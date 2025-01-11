extends CanvasLayer

var SuccessPopup = preload("res://scenes/ui/SuccessPopup.tscn")
var ErrorPopup = preload("res://scenes/ui/ErrorPopup.tscn")

func show_success_popup(message: String) -> void:
    clear_popups()
    var popup = SuccessPopup.instantiate()
    popup.get_node('Message').text = message
    
    
    popup.modulate.a = 0
    popup.scale = Vector2(0.5, 0.5)
    
    get_node('MarginContainer').add_child(popup)
    
    # Tween for the fade in transition
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(popup, "modulate:a", 1.0, 0.3)
    tween.tween_property(popup, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    
    # Setup for the removal
    var timer = get_tree().create_timer(3.7)
    timer.timeout.connect(_start_popup_removal.bind(popup))

func show_error_popup(message: String) -> void:
    clear_popups()
    var popup = ErrorPopup.instantiate()
    popup.get_node('Message').text = message
    
    # Initial properties for the transition
    popup.modulate.a = 0
    popup.scale = Vector2(0.5, 0.5)
    
    get_node('MarginContainer').add_child(popup)
    
    # Create fade in tween
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(popup, "modulate:a", 1.0, 0.3)
    tween.tween_property(popup, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    
    
    var timer = get_tree().create_timer(3.7)
    timer.timeout.connect(_start_popup_removal.bind(popup))

func _start_popup_removal(popup: Node) -> void:
    if is_instance_valid(popup) and popup.is_inside_tree():
        # Tween for the fade effect
        var tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(popup, "modulate:a", 0.0, 0.3) # Fade out
        tween.tween_property(popup, "scale", Vector2(0.8, 0.8), 0.3)
        # Remove popup after animation completes
        await tween.finished
        _remove_popup(popup)

func _remove_popup(popup: Node) -> void:
    if is_instance_valid(popup) and popup.is_inside_tree():
        popup.queue_free()

func clear_popups() -> void:
    var margin_container = get_node('MarginContainer')
    for child in margin_container.get_children():
        _start_popup_removal(child)