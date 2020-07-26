extends Node2D

export(float) var camera_change_speed = 0.3

onready var camera = $Camera2D
onready var tween = $Tween

var curr_char: PlayerCharacter
var party = []

func _ready():
	get_party()
	select_next_char()
	
func _physics_process(delta):
	watch_character_change()

func watch_character_change():
	if Input.is_action_just_pressed("change_char_next"):
		select_next_char()
	elif Input.is_action_just_pressed("change_char_prev"):
		select_prev_char()

func get_party():
	for node in get_children():
		if node is PlayerCharacter:
			party.append(node)

func select_next_char():
	if curr_char != null:
		camera.offset = curr_char.position
		curr_char.deselect()
		party.push_back(curr_char)
	curr_char = party.pop_front()
	activate_char()
	start_follow()

func select_prev_char():
	if curr_char != null:
		camera.offset = curr_char.position
		curr_char.deselect()
		party.push_front(curr_char)
	curr_char = party.pop_back()
	activate_char()
	start_follow()

func start_follow():
	for i in range(0, party.size()):
		var character = party[i]
		character.stop_follow()
		character.start_follow(curr_char, i + 1, party.size())

func activate_char():
	curr_char.select()
	pan_to_character()

func pan_to_character():
	camera.make_current()
	tween.interpolate_property(
		camera, "offset",
		camera.offset, curr_char.position,
		camera_change_speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()

func _on_Tween_tween_all_completed():
	curr_char.start_camera()
