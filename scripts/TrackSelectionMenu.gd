extends Control



@onready var carousel_container = $CarouselContainer
var items = []
var current_index = 0

# Configuration
var spacing = 700
var center_scale = Vector2(1.2, 1.2)
var side_scale = Vector2(0.8, 0.8)
var transition_time = 0.3

func _ready():
    # Get all carousel items
    items = carousel_container.get_children()
    
    
    
    # Initialize each item
    for item in items:
        # Set the pivot point to center
        item.custom_minimum_size = Vector2(600, 300)
        
        # item.pivot_offset = item.size / 2
        # Start all items at normal scale
        item.scale = Vector2(1, 1)
        # Ensure items are centered on their position
        item.position = -item.size / 2
        
    
    # Set initial positions
    update_carousel()

func update_carousel():
    for i in range(items.size()):
        var item = items[i]
        var relative_index = i - current_index
        
        # Calculate target position
        var target_position = Vector2(
            relative_index * spacing - item.size.x / 2,
            -item.size.y / 2
        )
        
        # Center item is scaled to be larger, rest are scaled down
        var target_scale
        if relative_index == 0:
            target_scale = center_scale
        else:
            target_scale = side_scale
        
        # Create tween for smooth transition
        var tween = create_tween()
        tween.set_parallel(true) # To play the transitions together, more natural
        
        # Position tween
        tween.tween_property(item, "position", target_position, transition_time)\
             .set_trans(Tween.TRANS_CUBIC)\
             .set_ease(Tween.EASE_OUT)
        
        # Scale tween
        tween.tween_property(item, "scale", target_scale, transition_time)\
             .set_trans(Tween.TRANS_CUBIC)\
             .set_ease(Tween.EASE_OUT)
        
        # The further the item, the more faded it should be (may need improving)
        var distance = abs(relative_index)
        var target_alpha = 1.0 if distance <= 1 else 0.5
        tween.tween_property(item, "modulate:a", target_alpha, transition_time)

func next_item():
    if current_index < items.size() - 1:
        current_index += 1
        update_carousel()

func previous_item():
    if current_index > 0:
        current_index -= 1
        update_carousel()

func _on_next_track_button_pressed():
    next_item()

func _on_previous_track_button_pressed():
    previous_item()
