tool
extends KinematicBody2D
class_name PlayerCharacter

export(int) 	var MAX_SPEED = 100
export(int) 	var FRICTION = 50
export(int) 	var ACCELERATION = 50
export(int) 	var FOLLOW_DISTANCE = 50
export(float) 	var MAX_FOLLOW_LAG = 0.5
export(float) 	var MIN_FOLLOW_LAG = 0.1

# setup for our texture
export(Texture) var texture = load("res://DinoSprites - vita.png")
export(int) 	var hframes = 24
export(int) 	var vframes = 1
export(int) 	var frame = 0

export(String) var character_name = "Vita"

onready var camera = $Camera2D
onready var sprite = $Sprite
onready var followLagTimer = $FollowLagTimer

enum {
	MOVE
	FOLLOW
	IDLE
}

var action_state = MOVE
var is_current_character = false
var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO

var leader 
var party_size
var position_in_party
var angle_to_leader = deg2rad(90)
var target_position

signal is_moving

func _ready():
	sprite.texture = texture
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.frame = frame

func _physics_process(delta):
	match action_state:
		MOVE:
			if (is_current_character):
				move_state(delta)
		FOLLOW:
			if (leader):
				follow_state(delta)
		IDLE:
			pass
			
func move_state(delta):
	input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
		emit_signal("is_moving")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			
		
	move()

func follow_state(delta):
	var follow_angle = party_angle()
	
	if leader.input_vector != Vector2.ZERO:
		angle_to_leader = leader.input_vector.angle() + deg2rad(follow_angle)
	var follow_vector = vector_from_angle(angle_to_leader)
	target_position = leader.position + follow_vector * FOLLOW_DISTANCE
	
	if position.distance_to(target_position) > 1:
		var direction = global_position.direction_to(target_position)
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
		move()
	else:
		action_state = IDLE
		should_start_timer = true

	
func vector_from_angle(angle):
	return Vector2(cos(angle), sin(angle))
	
func party_angle():

	var offset = position_in_party / 2.0
	if offset == 1:
		return 180
	if offset < 1:
		return 120
	if offset > 1:
		return 240
	
	
func move():
	velocity = move_and_slide(velocity)

func start_camera():
	camera.make_current()

func start_follow(current_character, _position_in_party, _party_size):
	action_state = IDLE
	position_in_party = _position_in_party
	party_size = _party_size
	leader = current_character
	leader.connect("is_moving", self, "_on_leader_move")
	should_start_timer = true

func stop_follow():
	if leader != null:
		leader.disconnect("is_moving", self, "_on_leader_move")
	should_start_timer = false
	followLagTimer.stop()

func select():
	is_current_character = true
	leader = null
	action_state = MOVE
	

func deselect():
	is_current_character = false
	action_state = IDLE
	should_start_timer = true
	followLagTimer.stop()

var should_start_timer = true

func _on_leader_move():
	if should_start_timer:
		should_start_timer = false
		var follow_lag = randf() * MAX_FOLLOW_LAG + MIN_FOLLOW_LAG
		followLagTimer.start(follow_lag)	

func _on_FollowLagTimer_timeout():
	followLagTimer.stop()
	action_state = FOLLOW
