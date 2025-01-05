extends Area2D

@export var health: int = 10
@export var damage: int = 5
@export var speed: float = 350
var player: Node2D = null
@onready var health_bar = $HealthBar
var death_animation = preload("res://Scenes/Explosion.tscn")
signal died(killed_by_player: bool)

var killed_by_player: bool = false

func _ready():
	add_to_group("Mobs")
	self.body_entered.connect(_on_body_entered)
	
	
	if health_bar:
		health_bar.max_value = health
		health_bar.value = health

func increase_stats(health_increase: int, damage_increase: int, speed_increase: float):
	health += health_increase
	damage += damage_increase
	speed += speed_increase
	
	if health_bar:
		health_bar.max_value = health
		health_bar.value = health

func _process(delta):
	if not player:
		player = get_tree().get_root().get_node("Game/Player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * speed * delta

func take_damage(amount: int):
	health -= amount
	health_bar.value = health
	if health <= 0:
		killed_by_player = true
		die()

func die():
	emit_signal("died", killed_by_player)
	call_deferred("_remove_self")

func _remove_self():
	var mob_death=death_animation.instantiate()
	mob_death.global_position=global_position
	get_parent().call_deferred("add_child", mob_death)
	
	if killed_by_player:
		_spawn_xp_drop()
	queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
		if body.shield_active:
			killed_by_player = true
		else:
			killed_by_player = false
		die()

func _spawn_xp_drop():
	var xp_drop_scene = preload("res://Scenes/XP.tscn")
	var xp_drop = xp_drop_scene.instantiate()
	xp_drop.position = global_position
	get_parent().add_child(xp_drop)
