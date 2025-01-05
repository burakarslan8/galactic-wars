class_name Weapon
extends Node2D

@export var bullet_scene: PackedScene
@export var attack_speed: float = 5.0
@export var damage: float = 10
@export var range: float = 2000.0
var time_since_last_shot: float = 0.0

func _process(delta: float) -> void:
	handle_shooting(delta)

func handle_shooting(delta: float) -> void:
	time_since_last_shot += delta
	var attack_cooldown = 1.0 / attack_speed
	if Input.is_action_pressed("shoot") and time_since_last_shot >= attack_cooldown:
		shoot()
		time_since_last_shot = 0.0

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	var game = get_tree().get_root().get_node("Game")
	game.add_child(bullet)
	
	var spawn_offset = 40.0
	var spawn_position = global_position + Vector2.RIGHT.rotated(global_rotation) * spawn_offset
	
	bullet.global_position = spawn_position
	bullet.rotation = global_rotation

	bullet.initialize_bullet(Vector2.RIGHT.rotated(global_rotation), self)

func update_bullet(new_bullet_scene: PackedScene):
	bullet_scene = new_bullet_scene
	print("Updated bullet to new type")

func get_total_damage() -> float:
	var player = get_tree().get_root().get_node("Game/Player")
	if player:
		return (damage + player.base_damage) * player.damage_multiplier
	return damage
