extends CharacterBody2D

var xp = 0
var level = 1
var camera: Camera2D = null

@onready var health_bar = get_parent().get_node("GUI/HealthBar")
@onready var xp_bar = get_parent().get_node("GUI/XPBar")
@onready var level_label = get_parent().get_node("GUI/LevelLabel")
@export var health_regen_rate: float = 0.5

@onready var map_collision = get_parent().get_node("StaticBody2D/CollisionShape2D")

@export var upgrades = {
	1: preload("res://Scenes/Ships/Ship_1.tscn"),
	5: preload("res://Scenes/Ships/Ship_5.tscn"),
	10: preload("res://Scenes/Ships/Ship_10.tscn"),
	15: preload("res://Scenes/Ships/Ship_15.tscn")
}

var current_ship = null
var current_health = 0
var max_health = 100
var speed = 700
var base_damage = 1.0
var shield_active: bool = false
var damage_multiplier: float = 1.0
var speed_multiplier: float = 1.0

var stat_increase_per_level = {
	"health": 5,
	"speed": 10,
	"damage": 0.5
}

@onready var shield_visual = $ShieldVisual

func _ready() -> void:
	camera = $Camera2D
	if camera:
		print("Camera attached to character")
	level_label.text = "LEVEL: " + str(level)
	xp_bar.value = xp % 10

	var regen_timer = Timer.new()
	regen_timer.wait_time = 1.0 / health_regen_rate
	regen_timer.autostart = true
	regen_timer.one_shot = false
	regen_timer.connect("timeout", Callable(self, "_regenerate_health"))
	add_child(regen_timer)

	spawn_ship(1)

func spawn_character(spawn_position: Vector2):
	position = spawn_position

func _process(delta):
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	velocity = velocity.normalized() * speed * speed_multiplier
	move_and_slide()
	rotate_towards_mouse()
	
	var collision_shape = map_collision.shape as RectangleShape2D
	var half_extents = collision_shape.extents
	var scale = map_collision.global_scale
	var scaled_extents = half_extents * scale 

	var map_position = map_collision.global_position

	position.x = clamp(position.x, map_position.x - scaled_extents.x, map_position.x + scaled_extents.x)
	position.y = clamp(position.y, map_position.y - scaled_extents.y, map_position.y + scaled_extents.y)

func spawn_ship(level):
	if upgrades.has(level):
		var new_ship_scene = upgrades[level].instantiate()

		if current_ship == null:
			current_ship = self
		
		for child in current_ship.get_children():
			if (child is Sprite2D and child.name != "ShieldVisual") or child is CollisionShape2D or child.name.begins_with("Weapon"):
				child.call_deferred("queue_free")
		
		for bullet in get_tree().get_nodes_in_group("Bullets"):
			bullet.queue_free()

		for child in new_ship_scene.get_children():
			var copied_child = child.duplicate()
			current_ship.call_deferred("add_child", copied_child)

		current_health = new_ship_scene.get("health")
		max_health = new_ship_scene.get("max_health")
		speed = new_ship_scene.get("speed")

		health_bar.max_value = max_health
		health_bar.value = current_health

		print("Upgraded to ship level:", level)

func _regenerate_health():
	if current_health < max_health:
		current_health += 1
		current_health = min(current_health, max_health)
		health_bar.value = current_health

func take_damage(amount):
	if shield_active:
		print("Shield blocked the damage!")
		return 
	current_health -= amount
	health_bar.value = current_health
	if current_health <= 0:
		die()

func die():
	var game = get_parent()
	game.game_over()

func rotate_towards_mouse() -> void:
	var mouse_position = get_global_mouse_position()
	var direction_to_mouse = (mouse_position - global_position).normalized()
	rotation = direction_to_mouse.angle()

func collect_xp(amount):
	xp += amount
	xp_bar.value = xp % 10
	if xp >= level * 10:
		level_up()

func level_up():
	level += 1
	level_label.text = "LEVEL: " + str(level)
	apply_stat_increase()
	
	if upgrades.has(level):
		spawn_ship(level)

func apply_stat_increase():
	max_health += stat_increase_per_level["health"]
	current_health = min(current_health + stat_increase_per_level["health"], max_health)
	speed += stat_increase_per_level["speed"]
	base_damage += stat_increase_per_level["damage"]

	health_bar.max_value = max_health
	health_bar.value = current_health

	print("Stats upgraded: Health:", max_health, "Speed:", speed, "Damage:", base_damage)

func activate_shield(duration: float):
	if shield_active:
		return
	shield_active = true
	shield_visual.visible = true

	print("Shield activated for", duration, "seconds")
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_deactivate_shield"))
	add_child(timer)
	timer.start()

func _deactivate_shield():
	shield_active = false
	shield_visual.visible = false
	print("Shield expired")

func boost_damage(multiplier: float, duration: float):
	damage_multiplier *= multiplier
	print("Damage boosted: x" + str(damage_multiplier))
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_reset_damage"))
	add_child(timer)
	timer.start()

func boost_speed(multiplier: float, duration: float):
	speed_multiplier *= multiplier
	print("Speed boosted: x" + str(speed_multiplier))
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_reset_speed"))
	add_child(timer)
	timer.start()

func _reset_damage():
	damage_multiplier = 1.0
	print("Damage boost expired")

func _reset_speed():
	speed_multiplier = 1.0
	print("Speed boost expired")
