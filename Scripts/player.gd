class_name Player
extends Node2D

var _id: String = ""
var _email: String = ""
var _password: String = ""
var _input: InputEventKey = null
var _input_mouse: InputEventMouse = null

var character: Character = null

func spawn_character(position_value: Vector2) -> void:
	character = preload("res://Scenes/Character.tscn").instantiate()
	add_child(character)
	
	character.position = position_value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var spawn_position = Vector2(100, 100)
	spawn_character(spawn_position)

func get_id():
	return _id

func set_id(id_value: String):
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
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_input(delta)
