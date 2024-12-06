extends CharacterBody2D

var rotation_speed = 4
var boost_force = 10

var drag = 0.98
var particles

# Called when the node enters the scene tree for the first time.
func _ready():
	particles = $RocketParticles
	
func _physics_process(delta):
	
	if Input.is_action_pressed("rotate_left"):
		rotate_left(delta)
	if Input.is_action_pressed("rotate_right"):
		rotate_right(delta)
	if Input.is_action_pressed("boost"):
		apply_boost()
	
	if velocity.length() < 55:
		particles.emitting = false
	else:
		particles.emitting = true
	velocity *= drag

	move_and_slide()
	#if (get_slide_collision_count() > 0):
		#print('game over')
	
func rotate_left(delta):
	rotation -= rotation_speed * delta
func rotate_right(delta):
	rotation += rotation_speed * delta
	
func apply_boost():
	velocity += Vector2.UP.rotated(rotation) * boost_force
	

func _on_restart_button_pressed() -> void:
	position.x = -461
	position.y = -258
	velocity = Vector2(0, 0)
	rotation = 0
