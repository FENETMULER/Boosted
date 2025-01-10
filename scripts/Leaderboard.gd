extends Control

var track_name: String = 'redd'

var global_leaderboard: Array = []
var local_leaderboard: Array = []

var country_codes = {
    "Afghanistan": "AF",
    "Albania": "AL",
    "Algeria": "DZ",
    "Andorra": "AD",
    "Angola": "AO",
    "Antigua and Barbuda": "AG",
    "Argentina": "AR",
    "Armenia": "AM",
    "Australia": "AU",
    "Austria": "AT",
    "Azerbaijan": "AZ",
    "Bahamas": "BS",
    "Bahrain": "BH",
    "Bangladesh": "BD",
    "Barbados": "BB",
    "Belarus": "BY",
    "Belgium": "BE",
    "Belize": "BZ",
    "Benin": "BJ",
    "Bhutan": "BT",
    "Bolivia": "BO",
    "Bosnia and Herzegovina": "BA",
    "Botswana": "BW",
    "Brazil": "BR",
    "Brunei": "BN",
    "Bulgaria": "BG",
    "Burkina Faso": "BF",
    "Burundi": "BI",
    "Cambodia": "KH",
    "Cameroon": "CM",
    "Canada": "CA",
    "Cape Verde": "CV",
    "Central African Republic": "CF",
    "Chad": "TD",
    "Chile": "CL",
    "China": "CN",
    "Colombia": "CO",
    "Comoros": "KM",
    "Congo": "CG",
    "Costa Rica": "CR",
    "Croatia": "HR",
    "Cuba": "CU",
    "Cyprus": "CY",
    "Czech Republic": "CZ",
    "Denmark": "DK",
    "Djibouti": "DJ",
    "Dominica": "DM",
    "Dominican Republic": "DO",
    "East Timor": "TL",
    "Ecuador": "EC",
    "Egypt": "EG",
    "El Salvador": "SV",
    "Equatorial Guinea": "GQ",
    "Eritrea": "ER",
    "Estonia": "EE",
    "Eswatini": "SZ",
    "Ethiopia": "ET",
    "Fiji": "FJ",
    "Finland": "FI",
    "France": "FR",
    "Gabon": "GA",
    "Gambia": "GM",
    "Georgia": "GE",
    "Germany": "DE",
    "Ghana": "GH",
    "Greece": "GR",
    "Grenada": "GD",
    "Guatemala": "GT",
    "Guinea": "GN",
    "Guinea-Bissau": "GW",
    "Guyana": "GY",
    "Haiti": "HT",
    "Honduras": "HN",
    "Hungary": "HU",
    "Iceland": "IS",
    "India": "IN",
    "Indonesia": "ID",
    "Iran": "IR",
    "Iraq": "IQ",
    "Ireland": "IE",
    "Israel": "IL",
    "Italy": "IT",
    "Jamaica": "JM",
    "Japan": "JP",
    "Jordan": "JO",
    "Kazakhstan": "KZ",
    "Kenya": "KE",
    "Kiribati": "KI",
    "Korea, North": "KP",
    "Korea, South": "KR",
    "Kuwait": "KW",
    "Kyrgyzstan": "KG",
    "Laos": "LA",
    "Latvia": "LV",
    "Lebanon": "LB",
    "Lesotho": "LS",
    "Liberia": "LR",
    "Libya": "LY",
    "Liechtenstein": "LI",
    "Lithuania": "LT",
    "Luxembourg": "LU",
    "Madagascar": "MG",
    "Malawi": "MW",
    "Malaysia": "MY",
    "Maldives": "MV",
    "Mali": "ML",
    "Malta": "MT",
    "Marshall Islands": "MH",
    "Mauritania": "MR",
    "Mauritius": "MU",
    "Mexico": "MX",
    "Micronesia": "FM",
    "Moldova": "MD",
    "Monaco": "MC",
    "Mongolia": "MN",
    "Montenegro": "ME",
    "Morocco": "MA",
    "Mozambique": "MZ",
    "Myanmar": "MM",
    "Namibia": "NA",
    "Nauru": "NR",
    "Nepal": "NP",
    "Netherlands": "NL",
    "New Zealand": "NZ",
    "Nicaragua": "NI",
    "Niger": "NE",
    "Nigeria": "NG",
    "North Macedonia": "MK",
    "Norway": "NO",
    "Oman": "OM",
    "Pakistan": "PK",
    "Palau": "PW",
    "Palestine": "PS",
    "Panama": "PA",
    "Papua New Guinea": "PG",
    "Paraguay": "PY",
    "Peru": "PE",
    "Philippines": "PH",
    "Poland": "PL",
    "Portugal": "PT",
    "Qatar": "QA",
    "Romania": "RO",
    "Russia": "RU",
    "Rwanda": "RW",
    "Saint Kitts and Nevis": "KN",
    "Saint Lucia": "LC",
    "Saint Vincent and the Grenadines": "VC",
    "Samoa": "WS",
    "San Marino": "SM",
    "Sao Tome and Principe": "ST",
    "Saudi Arabia": "SA",
    "Senegal": "SN",
    "Serbia": "RS",
    "Seychelles": "SC",
    "Sierra Leone": "SL",
    "Singapore": "SG",
    "Slovakia": "SK",
    "Slovenia": "SI",
    "Solomon Islands": "SB",
    "Somalia": "SO",
    "South Africa": "ZA",
    "South Sudan": "SS",
    "Spain": "ES",
    "Sri Lanka": "LK",
    "Sudan": "SD",
    "Suriname": "SR",
    "Sweden": "SE",
    "Switzerland": "CH",
    "Syria": "SY",
    "Taiwan": "TW",
    "Tajikistan": "TJ",
    "Tanzania": "TZ",
    "Thailand": "TH",
    "Togo": "TG",
    "Tonga": "TO",
    "Trinidad and Tobago": "TT",
    "Tunisia": "TN",
    "Turkey": "TR",
    "Turkmenistan": "TM",
    "Tuvalu": "TV",
    "Uganda": "UG",
    "Ukraine": "UA",
    "United Arab Emirates": "AE",
    "United Kingdom": "GB",
    "United States": "US",
    "Uruguay": "UY",
    "Uzbekistan": "UZ",
    "Vanuatu": "VU",
    "Vatican City": "VA",
    "Venezuela": "VE",
    "Vietnam": "VN",
    "Yemen": "YE",
    "Zambia": "ZM",
    "Zimbabwe": "ZW"
}

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

    var country_flag = item.get_node('HBoxContainer/CountryFlag');
    if item_data.country in country_codes:
        country_flag.texture = load('res://assets/flags/%s.png' % country_codes[item_data.country])


    var rank_label = item.get_node('HBoxContainer/RankLabel')
    rank_label.text = "%s. " % rank
    
    var username_label = item.get_node('HBoxContainer/UsernameLabel')
    username_label.text = item_data.username
    
    
    var time_label = item.get_node('HBoxContainer/TimeLabel')
    time_label.text = "%.2f" % item_data.time
    
    
    return item


func _on_close_button_pressed() -> void:
    OverlayManager.pop_overlay()