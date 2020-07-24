tool
extends KinematicBody2D
class_name PlayerCharacter

export(int) var MAX_SPEED = 100
export(int) var FRICTION = 50
export(int) var ACCELERATION = 50
export(int) var FOLLOW_DISTANCE = 40

export(Texture) var texture = load("res://DinoSprites - vita.png")
export(int) var hframes = 24
export(int) var vframes = 1
export(int) var frame = 0

export(String) var character_name = "Vita"

onready var camera = $Camera2D
onready var sprite = $Sprite


enum {
	MOVE
	FOLLOW
	IDLE
}

var state = MOVE
var is_current_character = false
var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO

var to_follow
var to_follow_angle = deg2rad(90)
var target_position
var party_number = 0

func _ready():
	sprite.texture = texture
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.frame = frame

func _physics_process(delta):
	match state:
		MOVE:
			if (is_current_character):
				move_state(delta)
		FOLLOW:
			if (to_follow):
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
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		
	move()

func follow_state(delta):

	var follow_angle = party_angle()
	
	if to_follow.input_vector != Vector2.ZERO:
		to_follow_angle = to_follow.input_vector.angle() + deg2rad(follow_angle)
	var opposite_vector = Vector2(cos(to_follow_angle), sin(to_follow_angle))
	target_position = to_follow.position + opposite_vector * FOLLOW_DISTANCE
	
	if position.distance_to(target_position) > 1:
		accelerate_toward(target_position)
		move()
	
func party_angle():
	if party_number == 0:
		return 110
	if party_number == 1:
		return 180
	if party_number == 2:
		return 250

func accelerate_toward(point):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)

func move():
	velocity = move_and_slide(velocity)

func start_camera():
	camera.make_current()

func follow(current_character, _party_number):
	state = FOLLOW
	party_number = _party_number
	to_follow = current_character
	to_follow_angle = Vector2.UP.angle() + deg2rad(party_angle())

func select():
	is_current_character = true
	to_follow = null
	state = MOVE

func deselect():
	is_current_character = false
	state = FOLLOW

	
