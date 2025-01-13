# Base class all tracks inherit from
extends Node2D
class_name Track

@onready var timer: Timer = Timer.new()
@onready var time_label: Label = $LevelUI/LevelUIWrapper/MarginContainer/HBoxContainer/Time
@onready var finish_line: Area2D = $FinishLine
@onready var pause_button: Button = $LevelUI/LevelUIWrapper/MarginContainer/HBoxContainer/PauseButton

var time_elapsed: float = 0
var is_race_started: bool = false
var track_name: String


var http_request: HTTPRequest

# Constants
const API_URL = env.API_URL
const BEST_SCORES_LOCATION = env.BEST_SCORES_LOCATION

func _ready():
    track_name = SceneManager.current_track
    add_child(timer)
    finish_line.body_entered.connect(_on_finish_line_body_entered)
    pause_button.pressed.connect(_on_pause_button_pressed)
    timer.timeout.connect(_on_timer_timeout)
    timer.one_shot = false
    timer.wait_time = 0.05 # How often timeout is fired
    
    # Setup HTTP request node
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.process_mode = Node.PROCESS_MODE_ALWAYS # So that request can still be processed when paused
    http_request.request_completed.connect(_on_score_upload_completed)
    
    setup_track()

func _input(event):
    if event.is_action_pressed("reset_track"):
        reset_track()
    if event.is_action_pressed("boost"):
        _on_player_started_moving()
        
func setup_track():
    time_elapsed = 0
    is_race_started = false
    time_label.text = "00.00"

func _on_player_started_moving():
    timer.start()
    if !is_race_started:
        print('-----player started moving----')
        is_race_started = true

func _on_timer_timeout():
    if is_race_started:
        time_elapsed += 0.05
        update_timer_display()

func update_timer_display():
    time_label.text = "%.2f" % formatTime(time_elapsed)

func _on_finish_line_body_entered(body):
    if body.is_in_group("player") and is_race_started:
        timer.stop()
        print('track completed!')
        save_best_score()
        show_track_finished_overlay()

func get_best_time() -> float:
    var file = FileAccess.open(BEST_SCORES_LOCATION, FileAccess.READ)
    
    if file:
        var json_string = file.get_as_text()
        var save_data = JSON.parse_string(json_string)
        if save_data and save_data.has(track_name):
            return save_data[track_name]
    return 0
    

func show_track_finished_overlay():
    get_tree().paused = true
    var overlay = preload('res://scenes/ui/TrackFinishedOverlay.tscn').instantiate()
    
    # Get the best time
    var best_time = get_best_time()
    var current_time_label = overlay.get_node('TrackFinishedOverlayWrapper/CurrentTimeLabel')
    current_time_label.text = 'current Time: %.2f' % formatTime(time_elapsed)
    var best_time_label = overlay.get_node('TrackFinishedOverlayWrapper/BestTimeLabel')
    best_time_label.text = 'Best Time: %.2f' % best_time
    # Button signals
    var restart_button = overlay.get_node('TrackFinishedOverlayWrapper/RestartButton')
    restart_button.pressed.connect(reset_track)

    var tracks_button = overlay.get_node('TrackFinishedOverlayWrapper/TracksButton')
    tracks_button.pressed.connect(func():
        SceneManager.change_scene("track_selection_menu")
        get_tree().paused = false
        OverlayManager.clear_overlays()
    )
    
    OverlayManager.push_overlay_node(overlay)

func save_best_score():
    # Get the previous best time from local storage
    var save_data = {}
    var file = FileAccess.open(BEST_SCORES_LOCATION, FileAccess.READ)
    
    
    if file:
        var json_string = file.get_as_text()
        print(json_string)
        save_data = JSON.parse_string(json_string)
    
    if save_data == null:
        save_data = {}
    
    # Check if current score is better (lower) than saved score
    var should_upload = false
    var time = formatTime(time_elapsed)
    if !save_data.has(track_name) or time < save_data[track_name]:
        save_data[track_name] = time
        should_upload = true
        
        # Save the new best time
        file = FileAccess.open(BEST_SCORES_LOCATION, FileAccess.WRITE)
        file.store_string(JSON.stringify(save_data))
    
    if should_upload:
        PopupManager.show_success_popup("New Best Time!")
        upload_score()
    else:
        print("Not a new best time!")

func createTimeHash(time: float) -> String:
    var combined = str(time) + track_name + env.TIME_HASH_SECRET
    var timeHash = combined.sha256_text()
    return timeHash

func formatTime(time: float) -> float:
    return floor(time * 100) / 100
    

func upload_score():
    # Get tokens from your auth system
    var access_token = AuthManager.access_token
    var id_token = AuthManager.id_token
    
    if !access_token or !id_token:
        print("Error: No authentication tokens available")
        return
    
    var headers = [
        "Content-Type: application/json",
        "Authorization: Bearer " + access_token
    ]
    var time = formatTime(time_elapsed)
    track_name = track_name.to_lower()
    var body = {
        
        "id_token": id_token,
        "trackName": track_name,
        "time": time,
        "timeHash": createTimeHash(time)
    }
    
    var json_body = JSON.stringify(body)
    
    var error = http_request.request(
        API_URL + "/leaderboard",
        headers,
        HTTPClient.METHOD_POST,
        json_body
    )
    
    if error != OK:
        print("An error occurred in the HTTP request")


func _on_pause_button_pressed():
    get_tree().paused = true
    OverlayManager.push_overlay("pause_menu")

func _on_score_upload_completed(result, response_code, headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    print(json)
    if response_code == 200:
        # var json = JSON.parse_string(body.get_string_from_utf8())
        # print(json)
        print("Score uploaded successfully!")
    else:
        PopupManager.show_error_popup("Error Uploading Time")

func reset_track():
    get_tree().paused = false
    OverlayManager.clear_overlays()
    timer.stop()
    is_race_started = false
    setup_track()
    $Rocket.reset_position()
    # Handling the case where the boost and reset are pressed at the same time
    if Input.is_action_pressed("boost"):
        _on_player_started_moving()