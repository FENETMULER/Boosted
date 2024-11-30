extends Node2D

var timer = Timer.new()
var time_passed = 0.0
var timer_label
var current_best_value
var restarted = false


# Called when the node enters the scene tree for the first time.
func _ready():
	timer_label = $CanvasLayer/Label
	current_best_value = $CanvasLayer/CurrentBestValue
	display_high_score()
	
	
	


func start_timer():
	timer.start(0.01)
func stop_timer():
	timer.stop()
	
func get_high_score():
	var config = ConfigFile.new()
	var error = config.load('user://highscore.cfg') # 0 means found/OK, other code means error
	if error == 0:
		return config.get_value("highscore", "score", 0)
	else:
		return 100

func set_high_score(score):
	var config = ConfigFile.new()
	config.set_value("highscore", "score", score)
	config.save("user://highscore.cfg")
	
func display_high_score():
	if (get_high_score() == 100):
		current_best_value.text = "--"
	else:
		current_best_value.text = format_time(get_high_score())
	
func _physics_process(delta):
	time_passed += delta
	var formatted_time = str(floor(time_passed * 100)/100)
	timer_label.text = formatted_time
	
func format_time(time):
	return str(floor(time * 100)/100)

func _on_finish_line_body_entered(body):
	if time_passed < get_high_score():
		set_high_score(time_passed)
		display_high_score()
	set_physics_process(false)
	print('Finish Line Crossed!!')


func _on_restart_button_pressed():
	restarted = true
	time_passed = 0
	timer_label.text = '0.0'
	set_physics_process(false)


func _on_up_button_pressed():
	if restarted == true:
		set_physics_process(true)
		restarted = false
