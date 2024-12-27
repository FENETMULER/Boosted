# AuthScreen.gd
extends Control

@onready var auth_manager = AuthManager

# Sign-in container and fields
@onready var signin_container = $SigninContainer
@onready var signin_username = $SigninContainer/UsernameInput
@onready var signin_password = $SigninContainer/PasswordInput

# Sign-up container and fields
@onready var signup_container = $SignupContainer
@onready var signup_username = $SignupContainer/UsernameInput
@onready var signup_password = $SignupContainer/PasswordInput
@onready var signup_country = $SignupContainer/CountrySelector

func _ready():
    # Start with signin view
    show_signup()
    _setup_country_options()
    
    # Connect signals from AuthManager
    auth_manager.auth_success.connect(_on_auth_success)
    auth_manager.auth_failed.connect(_on_auth_failed)

func _setup_country_options():
    # Add countries to the OptionButton
    var countries = [
        "United States",
        "Canada",
        "United Kingdom",
        "Australia",
        # Add more countries as needed
    ]
    
    for country in countries:
        signup_country.add_item(country)

func show_signin():
    signin_container.show()
    signup_container.hide()
    _clear_signin_fields()

func show_signup():
    signin_container.hide()
    signup_container.show()
    _clear_signup_fields()

func _clear_signin_fields():
    signin_username.text = ""
    signin_password.text = ""

func _clear_signup_fields():
    signup_username.text = ""
    signup_password.text = ""
    signup_country.selected = 0 # Reset country selection to first option

# Button handlers
func _on_goto_signup_button_pressed():
    show_signup()

func _on_goto_signin_button_pressed():
    show_signin()

func _on_signin_button_pressed():
    if not _validate_signin_fields():
        return
        
    var username = signin_username.text
    var password = signin_password.text
    auth_manager.sign_in(username, password)

func _on_signup_button_pressed():
    if not _validate_signup_fields():
        return
        
    var username = signup_username.text
    var password = signup_password.text
    var country = signup_country.get_item_text(signup_country.selected)
    
    auth_manager.sign_up(username, password, country)

# Validation
func _validate_signin_fields() -> bool:
    if signin_username.text.is_empty() or signin_password.text.is_empty():
        _show_error("Please fill in all fields")
        return false
    return true

func _validate_signup_fields() -> bool:
    if signup_username.text.is_empty() or signup_password.text.is_empty():
        _show_error("Please fill in all fields")
        return false
        
    if signup_username.text.length() < 3:
        _show_error("Username must be at least 3 characters")
        return false
        
    if signup_password.text.length() < 6:
        _show_error("Password must be at least 6 characters")
        return false
        
    return true

# Response handlers
func _on_auth_success():
    print("Authentication successful!")
    # Change to game scene or whatever comes next
    get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_auth_failed(error_message):
    _show_error(error_message)

func _show_error(message):
    # Implement your error display logic here
    # Example using a Label:
    var error_label = $ErrorLabel
    error_label.text = message
    error_label.show()
    
    # Hide the error after a few seconds
    await get_tree().create_timer(3.0).timeout
    error_label.hide()

# Optional: Add smooth transitions
# func show_signin_with_transition():
#     var tween = create_tween()
#     signup_container.modulate.a = 1
#     signin_container.modulate.a = 0
#     signin_container.show()
    
#     tween.tween_property(signup_container, "modulate:a", 0, 0.3)
#     tween.parallel().tween_property(signin_container, "modulate:a", 1, 0.3)
    
#     await tween.finished
#     signup_container.hide()
#     _clear_signin_fields()

# func show_signup_with_transition():
#     var tween = create_tween()
#     signin_container.modulate.a = 1
#     signup_container.modulate.a = 0
#     signup_container.show()
    
#     tween.tween_property(signin_container, "modulate:a", 0, 0.3)
#     tween.parallel().tween_property(signup_container, "modulate:a", 1, 0.3)
    
#     await tween.finished
#     signin_container.hide()
#     _clear_signup_fields()
