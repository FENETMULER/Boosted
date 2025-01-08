# Base class all tracks inherit from
extends Node2D
class_name Track

@onready var timer: Timer = Timer.new()
@onready var timer_label: Label = $LevelUI/LevelUIWrapper/Time
@onready var finish_line: Area2D = $FinishLine
@onready var pause_button: Button = $LevelUI/LevelUIWrapper/PauseButton

var time_elapsed: float = 0
var is_race_started: bool = false
var track_name: String = 'redd'

# Add HTTP request node
var http_request: HTTPRequest

# Constants for the API
const API_URL = "https://i83iwprcp3.execute-api.us-east-1.amazonaws.com/test/leaderboard"

func _ready():
    add_child(timer)
    finish_line.body_entered.connect(_on_finish_line_body_entered)
    pause_button.pressed.connect(_on_pause_button_pressed)
    timer.timeout.connect(_on_timer_timeout)
    timer.one_shot = false
    timer.wait_time = 0.05 # How often timeout is fired
    
    # Setup HTTP request node
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.process_mode = Node.PROCESS_MODE_ALWAYS
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
    timer_label.text = "00.00"

func _on_player_started_moving():
    if !is_race_started:
        print('-----player started moving----')
        timer.start()
        is_race_started = true

func _on_timer_timeout():
    if is_race_started:
        time_elapsed += 0.05
        update_timer_display()

func update_timer_display():
    timer_label.text = "%.2f" % time_elapsed

func _on_finish_line_body_entered(body):
    if body.is_in_group("player") and is_race_started:
        timer.stop()
        print('track completed!')
        save_best_score()
        show_track_finished_overlay()

func get_best_time() -> float:
    var save_path = "user://bestscores.save"
    var file = FileAccess.open(save_path, FileAccess.READ)
    
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
    current_time_label.text = 'current Time: %.2f' % time_elapsed
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
    var save_path = "user://bestscores.save"
    var file = FileAccess.open(save_path, FileAccess.READ)
    
    if file:
        var json_string = file.get_as_text()
        print(json_string)
        save_data = JSON.parse_string(json_string)
    
    if save_data == null:
        save_data = {}
    
    # Check if current score is better (lower) than saved score
    var should_upload = false
    if !save_data.has(track_name) or time_elapsed < save_data[track_name]:
        save_data[track_name] = time_elapsed
        should_upload = true
        
        # Save the new best time
        file = FileAccess.open(save_path, FileAccess.WRITE)
        file.store_string(JSON.stringify(save_data))
    
    if should_upload:
        upload_score()
    else:
        print("Not a new best time!")

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
    
    var body = {
        "id_token": id_token,
        "track": track_name.to_lower(),
        "score": time_elapsed
    }
    
    var json_body = JSON.stringify(body)
    
    var error = http_request.request(
        API_URL,
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
        # Need to show success message to player here
    else:
        pass
        # Handle error cases appropriately

func reset_track():
    get_tree().paused = false
    OverlayManager.clear_overlays()
    timer.stop()
    is_race_started = false
    setup_track()
    $Rocket.reset_position()