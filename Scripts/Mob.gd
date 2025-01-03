extends Area2D

@export var health: int = 10
@export var damage: int = 10
@export var speed: float = 500
var player: Node2D = null
@onready var health_bar = $ProgressBar


func _ready():
	add_to_group("Mobs")
	self.body_entered.connect(_on_body_entered)
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
		die()

func die():
	call_deferred("_remove_self")

func _remove_self():
	_spawn_xp_drop()
	queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
		die()

func _spawn_xp_drop():
	var xp_drop_scene = preload("res://Scenes/XP.tscn")
	var xp_drop = xp_drop_scene.instantiate()
	xp_drop.position = global_position
	get_parent().add_child(xp_drop)
