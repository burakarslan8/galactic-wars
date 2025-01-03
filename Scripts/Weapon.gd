class_name Weapon
extends Node2D

const MIN_MOUSE_DISTANCE: float = 1.0

@export var attack_speed: float = 5.0
@export var damage: float = 10
@export var range: float = 2000.0
var time_since_last_shot: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if should_hide_weapon():
		hide()
	else:
		show()
		rotate_towards_mouse()
	handle_shooting(delta)

func update_weapon_position():
	var mouse_position = get_global_mouse_position()
	var player_position = get_parent().global_position
	var direction = (mouse_position - player_position).normalized()
	position = direction * 150
	rotation = direction.angle()

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
	var attack_cooldown = 1.0 / attack_speed
	if Input.is_action_pressed("shoot") and time_since_last_shot >= attack_cooldown:
		shoot()
		time_since_last_shot = 0.0
	
	update_weapon_position()

func shoot() -> void:
	var bullet_scene = preload("res://Scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	var game = get_tree().get_root().get_node("Game")
	game.add_child(bullet)
	bullet.global_position = global_position
	bullet.initialize_bullet(Vector2.RIGHT.rotated(rotation), self)
