extends Control

var track_name: String = 'redd'

var global_leaderboard: Array = []
var local_leaderboard: Array = []

func _ready():
    fetch_leaderboards()


func fetch_leaderboards():
    print('-----Fetching Leaderboards-----')
    var http = HTTPRequest.new()
    add_child(http)
    http.request_completed.connect(_on_leaderboard_data_received)

    var id_token := ""
    var username := ""
    var access_token := ""

    if FileAccess.file_exists('user://auth_session.save'):
        var file = FileAccess.open('user://auth_session.save', FileAccess.READ)
        var json = JSON.new()
        json.parse(file.get_line())

        var save_data = json.get_data()
        file.close()

        if save_data and save_data.has('id_token'):
            id_token = save_data.get('id_token', '')
            username = save_data.get('username', '')
            access_token = save_data.get('access_token', '')
        else:
            print('No id_token found in session')
    
    # Create the URL with query parameters
    var base_url = "https://i83iwprcp3.execute-api.us-east-1.amazonaws.com/test/leaderboard"
    var query_params = "?id_token=%s&trackName=%s" % [id_token.uri_encode(), track_name.uri_encode()]
    var url = base_url + query_params
    
    
    var headers = [
        "Authorization: Bearer %s" % access_token,
        "Content-Type: application/json"
        ]
    var result = http.request(url, headers, HTTPClient.METHOD_GET)
    if result != OK:
        print("An error occurred in the HTTP request")

func _on_leaderboard_data_received(result, response_code, headers, body):
    print('----- Data Received -----')
    if result != HTTPRequest.RESULT_SUCCESS:
        print("Failed to get leaderboard data")
        return
        
    var json = JSON.parse_string(body.get_string_from_utf8())
    if json == null:
        print("Failed to parse response")
        return
    print('----- data -----%s'%json)
    # Assuming the API returns an object with both leaderboards
    if json.has("globalLeaderboard") and json.has("localLeaderboard"):
        global_leaderboard = json["globalLeaderboard"]
        local_leaderboard = json["localLeaderboard"]
        display_leaderboards()

func display_leaderboards():
    # Assuming you have two VBoxContainer nodes for each leaderboard
    var global_container = $LeaderboardWrapper/GlobalScrollContainer/VBoxContainer
    var local_container = $LeaderboardWrapper/LocalScrollContainer/VBoxContainer
    
    # Clear existing entries
    for child in global_container.get_children():
        child.queue_free()
    for child in local_container.get_children():
        child.queue_free()
    
    # Populate global leaderboard
    for i in range(global_leaderboard.size()):
        var entry = global_leaderboard[i]
        var leaderboard_item = create_leaderboard_item(entry, i + 1)
        global_container.add_child(leaderboard_item)

    for i in range(local_leaderboard.size()):
        var entry = local_leaderboard[i]
        var leaderboard_item = create_leaderboard_item(entry, i + 1)
        local_container.add_child(leaderboard_item)
    
    
func create_leaderboard_item(item_data: Dictionary, rank: int) -> Node:
    var item = preload("res://scenes/ui/LeaderboardItem.tscn").instantiate()

    var rank_label = item.get_node('HBoxContainer/RankLabel')
    rank_label.text = "%s. " % rank
    
    var username_label = item.get_node('HBoxContainer/UsernameLabel')
    username_label.text = item_data.username
    
    
    var time_label = item.get_node('HBoxContainer/TimeLabel')
    time_label.text = "%.2f" % item_data.time
    
    
    return item


func _on_close_button_pressed() -> void:
    OverlayManager.pop_overlay()