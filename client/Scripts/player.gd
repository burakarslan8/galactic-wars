class_name Player
extends Node2D

var _id: int = 0
var _email: String = ""
var _password: String = ""
var _input: InputEventKey = null
var _input_mouse: InputEventMouse = null

var character: Character = null

func _ready() -> void:
	if multiplayer.get_unique_id() == _id:
		var spawn_position = Vector2(0, 0)
		spawn_character(spawn_position)

func spawn_character(position_value: Vector2) -> void:
	if character == null:
		character = preload("res://Scenes/Character.tscn").instantiate()
		add_child(character)
		character.position = position_value

func get_id():
	return _id

func set_id(id_value: int):
	_id = id_value

func get_email():
	return _email

func set_email(email_value: String):
	_email = email_value

func get_password():
	return _password

func set_password(password_value: String):
	_password = password_value

func get_input():
	return _input

func get_input_mouse():
	return _input_mouse

func handle_input(delta: float) -> void:
	if character == null:
		return

	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1

	# normalize the vector for consistent diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

	character.move(input_vector, delta)
	if multiplayer.get_unique_id() != 1:
		get_node("/root/Multiplayer").rpc_id(1, "update_player_position", multiplayer.get_unique_id(), character.position)

func _process(delta: float) -> void:
	if multiplayer.get_unique_id() == _id:
		handle_input(delta)
