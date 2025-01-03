class_name Bullet
extends Area2D

@export var speed: float = 1000.0
var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var weapon: Weapon = null

func _ready() -> void:
	add_to_group("Bullets")
	self.area_entered.connect(_on_body_entered)
func _process(delta: float) -> void:
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()

	if weapon and not weapon.is_queued_for_deletion() and distance_traveled >= weapon.range:
		queue_free()

func initialize_bullet(direction_value: Vector2, weapon_instance: Weapon) -> void:
	direction = direction_value.normalized()
	weapon = weapon_instance

func _on_body_entered(body):
	if body.is_in_group("Mobs"):
		body.take_damage(weapon.damage)
		queue_free()
