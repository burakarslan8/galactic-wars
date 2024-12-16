class_name Character
extends Node2D

var _health: float = 100.0
var _speed: float = 500.0
var _velocity: Vector2 = Vector2.ZERO
var camera: Camera2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = $Camera2D
	if camera:
		print("Camera attached to character")

func get_health() -> float:
	return _health

func set_health(health_value: float) -> void:
	_health = health_value

func get_speed() -> float:
	return _speed

func set_speed(speed_value: float) -> void:
	_speed = speed_value

func get_velocity() -> Vector2:
	return _velocity

func set_velocity(velocity_value: Vector2) -> void:
	_velocity = velocity_value

func move(direction: Vector2, delta: float) -> void:
	set_velocity(direction * get_speed())
	position += get_velocity() * delta
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_towards_mouse()

func rotate_towards_mouse() -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var direction_to_mouse = (get_global_mouse_position() - global_position).normalized()
	rotation = direction_to_mouse.angle() + PI / 2
