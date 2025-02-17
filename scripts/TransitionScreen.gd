extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer


signal transition_finished
func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(animation_name: String) -> void:
	if animation_name == 'fade_in':
		animation_player.play('fade_out')
	else:
		transition_finished.emit()
		color_rect.visible = false

func show_transition() -> void:
	color_rect.visible = true
	animation_player.play('fade_in')
