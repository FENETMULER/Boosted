extends Track


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	var button = $LevelUI/LevelUIWrapper/UpButtonContainer/UpButton
	button.pressed.connect(_on_player_started_moving)
