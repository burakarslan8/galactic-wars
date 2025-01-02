class_name Bullet
extends Area2D

var _speed: float = 1000.0
var _direction: Vector2 = Vector2.ZERO
var _distance_traveled: float = 0.0

var weapon: Weapon = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)

func get_speed() -> float:
	return _speed

func set_speed(speed_value: float) -> void:
	_speed = speed_value

func get_direction() -> Vector2:
	return _direction

func set_direction(direction_value: Vector2) -> void:
	_direction = direction_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement = _direction * get_speed() * delta
	position += movement

	_distance_traveled += movement.length()

	if weapon and _distance_traveled >= weapon.get_range():
		queue_free()

func initialize_bullet(direction: Vector2, weapon: Weapon) -> void:
	set_direction(direction.normalized())
	self.weapon = weapon