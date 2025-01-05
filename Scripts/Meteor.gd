extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO
var health = 20
var death_animation = preload("res://Scenes/Explosion.tscn")
var killed_by_player = false

var powerup_scenes = [
	preload("res://Scenes/PowerUps/ShieldPowerUp.tscn"),
	preload("res://Scenes/PowerUps/DamagePowerUp.tscn"),
	preload("res://Scenes/PowerUps/SpeedPowerUp.tscn")
]

func _ready():
	add_to_group("Meteors")
	animated_sprite.play("fall")
	self.connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float):
	position += direction * speed * delta
	
	rotation = direction.angle()

func initialize(target_position: Vector2):
	direction = (target_position - global_position).normalized()
	rotation = direction.angle() 

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(10)
		if body.shield_active:
			killed_by_player = true
		else:
			killed_by_player = false
		die()

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		killed_by_player = true
		die()

func die():
	call_deferred("_remove_self")
	
func _remove_self():
	var meteor_death=death_animation.instantiate()
	meteor_death.global_position=global_position
	get_parent().call_deferred("add_child", meteor_death)
	
	if killed_by_player:
		spawn_powerup()

	queue_free()

func spawn_powerup():
	var rng = RandomNumberGenerator.new()
	if rng.randf() < 0.2:
		var powerup_scene = powerup_scenes[rng.randi_range(0, powerup_scenes.size() - 1)]
		var powerup = powerup_scene.instantiate()
		powerup.position = global_position
		get_parent().add_child(powerup)
