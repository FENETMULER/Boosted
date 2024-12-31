extends Node

signal auth_success
signal auth_failed(error_message)
signal auth_state_changed(is_authenticated)

const API_ENDPOINT = "https://i83iwprcp3.execute-api.us-east-1.amazonaws.com/test"

var access_token = ""
var id_token = ""
var refresh_token = ""
var username = ""
var is_authenticated = false

@onready var auth_request = HTTPRequest.new()

func _ready():
    add_child(auth_request)
    auth_request.request_completed.connect(_on_auth_request_completed)
    # Try to restore session on startup
    _restore_session()

func _restore_session():
    if FileAccess.file_exists("user://auth_session.save"):
        var file = FileAccess.open("user://auth_session.save", FileAccess.READ)
        var json = JSON.new()
        json.parse(file.get_line())
		
        var save_data = json.get_data()
        print(save_data)
        file.close()
        
        if save_data and save_data.has("id_token"):

            print('-------------restoring session-------------')
            access_token = save_data.get("access_token", "")
            id_token = save_data.get("id_token", "")
            refresh_token = save_data.get("refresh_token", "")
            username = save_data.get("username", "")
            
            
            # Validate the session
            _validate_session()
            return true
    
    is_authenticated = false
    auth_state_changed.emit(false)
    return false

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
	

func sign_in(username_: String, password: String):
    username = username_
    
    var data = {
        "username": username,
        "password": password
    }
    
    var headers = ["Content-Type: application/json"]
    
    auth_request.request(
        API_ENDPOINT + "/auth/signin",
        headers,
        HTTPClient.METHOD_POST,
        JSON.stringify(data)
    )

func _validate_session():
    if access_token.is_empty():
        is_authenticated = false
        auth_state_changed.emit(false)
        return
        
    var headers = [
        "Authorization: Bearer " + access_token,
        "Content-Type: application/json"
    ]
    print('-------------Validating token-----------------')
    auth_request.request(
        API_ENDPOINT + "/auth/validate",
        headers,
        HTTPClient.METHOD_GET,
        ""
    )

func _on_auth_request_completed(_result, response_code, _headers, body):
    var json = JSON.new()
    json.parse(body.get_string_from_utf8())
    var response = json.get_data()
    print(response_code)
    match response_code:
        200: # Success
            if response.has("accessToken"):
                access_token = response.get("accessToken")
            if response.has("idToken"):
                id_token = response.get("idToken")
            if response.has("refreshToken"):
                refresh_token = response.get("refreshToken")
                
            print('-----------token valid------------')
            is_authenticated = true
            _save_user_session()
            auth_success.emit()
            auth_state_changed.emit(true)
            
        401: # Unauthorized - try refresh
            print('-----------token invalid------------')
            _refresh_token()
            
        _: # Other errors
            print('-----------unknown error------------')
            var error_message = "Unknown error"
            if response.has("message"):
                error_message = response.message
            
            is_authenticated = false
            auth_failed.emit(error_message)
            auth_state_changed.emit(false)

func _save_user_session():
    var save_data = {
        "access_token": access_token,
        "id_token": id_token,
        "refresh_token": refresh_token,
        "username": username
    }
    var file = FileAccess.open("user://auth_session.save", FileAccess.WRITE)
    file.store_line(JSON.stringify(save_data))
    file.close()

func _refresh_token():
    if refresh_token.is_empty():
        sign_out()
        return
        
    var data = {
        "refresh_token": refresh_token
    }
    
    var headers = ["Content-Type: application/json"]
    
    auth_request.request(
        API_ENDPOINT + "/auth/refresh",
        headers,
        HTTPClient.METHOD_POST,
        JSON.stringify(data)
    )

func sign_out():
    access_token = ""
    id_token = ""
    refresh_token = ""
    username = ""
    is_authenticated = false
    
    if FileAccess.file_exists("user://auth_session.save"):
        DirAccess.remove_absolute("user://auth_session.save")
    
    auth_state_changed.emit(false)
