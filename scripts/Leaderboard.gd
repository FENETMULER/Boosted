extends Control

var track_name: String = 'redd'

var global_leaderboard: Array = []
var local_leaderboard: Array = []

var country_codes = {
    "Afghanistan": "af",
    "Albania": "al",
    "Algeria": "dz",
    "Andorra": "ad",
    "Angola": "ao",
    "Antigua and Barbuda": "ag",
    "Argentina": "ar",
    "Armenia": "am",
    "Australia": "au",
    "Austria": "at",
    "Azerbaijan": "az",
    "Bahamas": "bs",
    "Bahrain": "bh",
    "Bangladesh": "bd",
    "Barbados": "bb",
    "Belarus": "by",
    "Belgium": "be",
    "Belize": "bz",
    "Benin": "bj",
    "Bhutan": "bt",
    "Bolivia": "bo",
    "Bosnia and Herzegovina": "ba",
    "Botswana": "bw",
    "Brazil": "br",
    "Brunei": "bn",
    "Bulgaria": "bg",
    "Burkina Faso": "bf",
    "Burundi": "bi",
    "Cambodia": "kh",
    "Cameroon": "cm",
    "Canada": "ca",
    "Cape Verde": "cv",
    "Central African Republic": "cf",
    "Chad": "td",
    "Chile": "cl",
    "China": "cn",
    "Colombia": "co",
    "Comoros": "km",
    "Congo": "cg",
    "Costa Rica": "cr",
    "Croatia": "hr",
    "Cuba": "cu",
    "Cyprus": "cy",
    "Czech Republic": "cz",
    "Denmark": "dk",
    "Djibouti": "dj",
    "Dominica": "dm",
    "Dominican Republic": "do",
    "East Timor": "tl",
    "Ecuador": "ec",
    "Egypt": "eg",
    "El Salvador": "sv",
    "Equatorial Guinea": "gq",
    "Eritrea": "er",
    "Estonia": "ee",
    "Eswatini": "sz",
    "Ethiopia": "et",
    "Fiji": "fj",
    "Finland": "fi",
    "France": "fr",
    "Gabon": "ga",
    "Gambia": "gm",
    "Georgia": "ge",
    "Germany": "de",
    "Ghana": "gh",
    "Greece": "gr",
    "Grenada": "gd",
    "Guatemala": "gt",
    "Guinea": "gn",
    "Guinea-Bissau": "gw",
    "Guyana": "gy",
    "Haiti": "ht",
    "Honduras": "hn",
    "Hungary": "hu",
    "Iceland": "is",
    "India": "in",
    "Indonesia": "id",
    "Iran": "ir",
    "Iraq": "iq",
    "Ireland": "ie",
    "Israel": "il",
    "Italy": "it",
    "Jamaica": "jm",
    "Japan": "jp",
    "Jordan": "jo",
    "Kazakhstan": "kz",
    "Kenya": "ke",
    "Kiribati": "ki",
    "Korea, North": "kp",
    "Korea, South": "kr",
    "Kuwait": "kw",
    "Kyrgyzstan": "kg",
    "Laos": "la",
    "Latvia": "lv",
    "Lebanon": "lb",
    "Lesotho": "ls",
    "Liberia": "lr",
    "Libya": "ly",
    "Liechtenstein": "li",
    "Lithuania": "lt",
    "Luxembourg": "lu",
    "Madagascar": "mg",
    "Malawi": "mw",
    "Malaysia": "my",
    "Maldives": "mv",
    "Mali": "ml",
    "Malta": "mt",
    "Marshall Islands": "mh",
    "Mauritania": "mr",
    "Mauritius": "mu",
    "Mexico": "mx",
    "Micronesia": "fm",
    "Moldova": "md",
    "Monaco": "mc",
    "Mongolia": "mn",
    "Montenegro": "me",
    "Morocco": "ma",
    "Mozambique": "mz",
    "Myanmar": "mm",
    "Namibia": "na",
    "Nauru": "nr",
    "Nepal": "np",
    "Netherlands": "nl",
    "New Zealand": "nz",
    "Nicaragua": "ni",
    "Niger": "ne",
    "Nigeria": "ng",
    "North Macedonia": "mk",
    "Norway": "no",
    "Oman": "om",
    "Pakistan": "pk",
    "Palau": "pw",
    "Palestine": "ps",
    "Panama": "pa",
    "Papua New Guinea": "pg",
    "Paraguay": "py",
    "Peru": "pe",
    "Philippines": "ph",
    "Poland": "pl",
    "Portugal": "pt",
    "Qatar": "qa",
    "Romania": "ro",
    "Russia": "ru",
    "Rwanda": "rw",
    "Saint Kitts and Nevis": "kn",
    "Saint Lucia": "lc",
    "Saint Vincent and the Grenadines": "vc",
    "Samoa": "ws",
    "San Marino": "sm",
    "Sao Tome and Principe": "st",
    "Saudi Arabia": "sa",
    "Senegal": "sn",
    "Serbia": "rs",
    "Seychelles": "sc",
    "Sierra Leone": "sl",
    "Singapore": "sg",
    "Slovakia": "sk",
    "Slovenia": "si",
    "Solomon Islands": "sb",
    "Somalia": "so",
    "South Africa": "za",
    "South Sudan": "ss",
    "Spain": "es",
    "Sri Lanka": "lk",
    "Sudan": "sd",
    "Suriname": "sr",
    "Sweden": "se",
    "Switzerland": "ch",
    "Syria": "sy",
    "Taiwan": "tw",
    "Tajikistan": "tj",
    "Tanzania": "tz",
    "Thailand": "th",
    "Togo": "tg",
    "Tonga": "to",
    "Trinidad and Tobago": "tt",
    "Tunisia": "tn",
    "Turkey": "tr",
    "Turkmenistan": "tm",
    "Tuvalu": "tv",
    "Uganda": "ug",
    "Ukraine": "ua",
    "United Arab Emirates": "ae",
    "United Kingdom": "gb",
    "United States": "us",
    "Uruguay": "uy",
    "Uzbekistan": "uz",
    "Vanuatu": "vu",
    "Vatican City": "va",
    "Venezuela": "ve",
    "Vietnam": "vn",
    "Yemen": "ye",
    "Zambia": "zm",
    "Zimbabwe": "zw"
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