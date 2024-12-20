class_name Weapon
extends Node2D

const ROTATION_RADIUS: float = 150
const MIN_MOUSE_DISTANCE: float = 1.0

var _attack_speed: float = 5.0
var _damage: float = 10
var _range: float = 2000.0
var time_since_last_shot: float = 0.0

func get_attack_speed() -> float:
	return _attack_speed

func set_attack_speed(attack_speed_value: float) -> void:
	_attack_speed = attack_speed_value

func get_damage() -> float:
	return _damage

func set_damage(damage_value: float) -> void:
	_damage = damage_value

func get_range() -> float:
	return _range

func set_range(range_value: float) -> void:
	_range = range_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if should_hide_weapon():
		hide()
	else:
		show()
		update_position()
		rotate_towards_mouse()
	handle_shooting(delta)

func update_position() -> void:
	var mouse_position = get_global_mouse_position()
	var character_center = get_parent().global_position
	var direction_to_mouse = (mouse_position - character_center).normalized()
	var angle_to_mouse = direction_to_mouse.angle()

	var offset_x = ROTATION_RADIUS * cos(angle_to_mouse)
	var offset_y = ROTATION_RADIUS * sin(angle_to_mouse)
	position = Vector2(offset_x, offset_y)

func rotate_towards_mouse() -> void:
	var mouse_position = get_global_mouse_position()
	var character_center = get_parent().global_position
	var direction_to_mouse = (mouse_position - character_center).normalized()
	rotation = direction_to_mouse.angle()

func should_hide_weapon() -> bool:
	var mouse_position = get_global_mouse_position()
	var character_center = get_parent().global_position
	var distance_to_mouse = character_center.distance_to(mouse_position)
	return distance_to_mouse < MIN_MOUSE_DISTANCE

func handle_shooting(delta: float) -> void:
	time_since_last_shot += delta
	var attack_cooldown = 1.0 / get_attack_speed()
	if Input.is_action_pressed("shoot") and time_since_last_shot >= attack_cooldown:
		shoot()
		time_since_last_shot = 0.0

func shoot() -> void:
	var bullet_scene = preload("res://Scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position
	bullet.initialize_bullet(Vector2.RIGHT.rotated(global_rotation), self)
