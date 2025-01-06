# Base class all tracks inherit from
extends Node2D
class_name Track

@onready var timer: Timer = Timer.new()
@onready var timer_label: Label = $LevelUI/LevelUIWrapper/Time
@onready var finish_line: Area2D = $FinishLine
# @onready var track_name_label: Label = $TrackNameLabel

var time_elapsed: float = 0
var is_race_started: bool = false
var track_name: String


func _ready():
    add_child(timer)
    finish_line.body_entered.connect(_on_finish_line_body_entered)
    timer.timeout.connect(_on_timer_timeout)
    timer.one_shot = false
    timer.wait_time = 0.05 # How often timeout is fired
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
    # track_name_label.text = track_name

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
        # show_completion_popup()

# func load_best_time():
#     var save_path = "user://track_%s.save" % track_name.to_lower().replace(" ", "_")
#     if FileAccess.file_exists(save_path):
#         var file = FileAccess.open(save_path, FileAccess.READ)
#         best_time = file.get_float()

# func save_best_time():
#     var save_path = "user://track_%s.save" % track_name.to_lower().replace(" ", "_")
#     var file = FileAccess.open(save_path, FileAccess.WRITE)
#     file.store_float(best_time)

# func show_completion_popup():
#     $CompletionPopup.show_results(time_elapsed, best_time)

func reset_track():
    timer.stop()
    is_race_started = false
    setup_track()
    $Rocket.reset_position()