# AuthManager.gd
extends Node

signal auth_success
signal auth_failed(error_message)

# API Configuration
const API_ENDPOINT = "https://i83iwprcp3.execute-api.us-east-1.amazonaws.com/test" # e.g., "https://api.yourdomain.com/dev"
var user_token = ""
var username = ""

# HTTP request nodes
@onready var auth_request = HTTPRequest.new()
@onready var api_request = HTTPRequest.new()

func _ready():
	add_child(auth_request)
	add_child(api_request)
	auth_request.request_completed.connect(_on_auth_request_completed)

func sign_up(new_username: String, password: String, country: String):
	username = new_username
	
	var data = {
		"username": username,
		"password": password,
		"country": country
	}
	
	var headers = ["Content-Type: application/json"]
	
	auth_request.request(
		API_ENDPOINT + "/auth/signup",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)


func _on_auth_request_completed(_result, response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = JSON.parse_string(json.get_data()['body'])
    
	
	# if response_code == 200:
	# 	user_token = response['token']
	# 	username = response['username']
	# 	_save_user_session()
	# 	auth_success.emit()
	# else:
	# 	var error_message = "Unknown error"
	# 	if response.has("message"):
	# 		error_message = response.message
	# 	auth_failed.emit(error_message)


func _save_user_session():
	var save_data = {
		"token": user_token,
		"username": username
	}
	var file = FileAccess.open("user://auth_session.save", FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()

# func load_session() -> bool:
# 	if not FileAccess.file_exists("user://auth_session.save"):
# 		return false
		
# 	var file = FileAccess.open("user://auth_session.save", FileAccess.READ)
# 	var json = JSON.new()
# 	json.parse(file.get_line())
# 	var save_data = json.get_data()
# 	file.close()
	
# 	if save_data:
# 		user_token = save_data.token
# 		username = save_data.username
# 		return true
# 	return false

func sign_out():
	user_token = ""
	username = ""
	if FileAccess.file_exists("user://auth_session.save"):
		DirAccess.remove_absolute("user://auth_session.save")
