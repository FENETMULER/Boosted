# Base class all tracks inherit from
extends Node2D
class_name Track

@onready var timer: Timer = Timer.new()
@onready var timer_label: Label = $LevelUI/LevelUIWrapper/Time
# @onready var track_name_label: Label = $TrackNameLabel

var time_elapsed: float = 0
var is_race_started: bool = false
var track_name: String
var best_time: float = 999999.0

func _ready():
    add_child(timer)
    timer.timeout.connect(_on_timer_timeout)
    timer.one_shot = false
    timer.wait_time = 0.1
    setup_track()
    load_best_time()

func setup_track():
    time_elapsed = 0
    is_race_started = false
    timer_label.text = "00:00.00"
    # track_name_label.text = track_name

func _on_player_started_moving():
    print('-----player started moving----')
    if !is_race_started:
        timer.start()
        is_race_started = true

func _on_timer_timeout():
    if is_race_started:
        time_elapsed += 0.1
        update_timer_display()

func update_timer_display():
    var minutes = int(time_elapsed / 60)
    var seconds = fmod(time_elapsed, 60)
    timer_label.text = "%02d:%02.2f" % [minutes, seconds]

func _on_finish_line_body_entered(body):
    if body.is_in_group("player") and is_race_started:
        timer.stop()
        is_race_started = false
        if time_elapsed < best_time:
            best_time = time_elapsed
            save_best_time()
        # show_completion_popup()

func load_best_time():
    var save_path = "user://track_%s.save" % track_name.to_lower().replace(" ", "_")
    if FileAccess.file_exists(save_path):
        var file = FileAccess.open(save_path, FileAccess.READ)
        best_time = file.get_float()

func save_best_time():
    var save_path = "user://track_%s.save" % track_name.to_lower().replace(" ", "_")
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    file.store_float(best_time)

# func show_completion_popup():
#     $CompletionPopup.show_results(time_elapsed, best_time)

func reset_track():
    timer.stop()
    setup_track()
    $Player.reset_position()