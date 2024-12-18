extends HBoxContainer


@export var active_dot_color: Color
@export var inactive_dot_color: Color
@onready var dots: Array[Node] = get_children()

func _ready():
	get_parent().carousel_changed.connect(_on_carousel_changed)


func _on_carousel_changed(index):
	for i in range(dots.size()):
		if i == index:
			dots[i].self_modulate = active_dot_color
		else:
			dots[i].self_modulate = inactive_dot_color
