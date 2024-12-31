extends CanvasLayer

@onready var auth_manager = AuthManager
@onready var play_button = $MainMenuWrapper/VBoxContainer/Play
@onready var quit_button = $MainMenuWrapper/VBoxContainer/Quit
@onready var auth_screen = preload("res://scenes/AuthScreen.tscn").instantiate()
# @onready var loading_indicator = $LoadingIndicator

func _ready():
	# Connect to auth signals
	auth_manager.auth_success.connect(_on_auth_success)
	auth_manager.auth_failed.connect(_on_auth_failed)
	auth_manager.auth_state_changed.connect(_on_auth_state_changed)
	
	# # Hide auth screen initially
	# if auth_screen:
	#     auth_screen.hide()
	
	# Update UI based on initial auth state
	_on_auth_state_changed(auth_manager.is_authenticated)

func _on_play_button_pressed() -> void:
	print('play button pressed')
	if auth_manager.is_authenticated:
		SceneManager.change_scene('track_selection_menu')
	else:
		show_auth_screen()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_auth_success():
	if auth_screen:
		auth_screen.hide()
	# SceneManager.change_scene('track_selection_menu')

func _on_auth_failed(error_message):
	if has_node("ErrorLabel"):
		$ErrorLabel.text = error_message
		$ErrorLabel.show()

func _on_auth_state_changed(is_authenticated):
	if is_authenticated:
		play_button.text = "Play"
		$MainMenuWrapper/Username.text = auth_manager.username
		if auth_screen:
			auth_screen.hide()
	else:
		play_button.text = "Sign In to Play"

func show_auth_screen():
	if auth_screen:
		SceneManager.change_scene('auth_screen')
	else:
		push_error("Auth screen not found! Make sure to add it as a child node.")
