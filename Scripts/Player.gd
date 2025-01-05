extends CharacterBody2D

var speed = 700
var health = 100
var xp = 0
var level = 1
var camera: Camera2D = null
var weapon: Weapon = null

@export var max_health: int = 100
@onready var health_bar = get_parent().get_node("GUI/HealthBar")
@onready var xp_bar = get_parent().get_node("GUI/XPBar")
@onready var level_label = get_parent().get_node("GUI/LevelLabel")
@export var health_regen_rate: float = 0.5
@onready var map_collision = get_parent().get_node("StaticBody2D/CollisionShape2D")

func _ready() -> void:
	camera = $Camera2D
	if camera:
		print("Camera attached to character")
	health_bar.max_value = health
	health_bar.value = health
	xp_bar.max_value = 10
	xp_bar.value = xp % 10
	level_label.text = "LEVEL: " + str(level)
	
	var regen_timer = Timer.new()
	regen_timer.wait_time = 1.0 / health_regen_rate
	regen_timer.autostart = true
	regen_timer.one_shot = false
	regen_timer.connect("timeout", Callable(self, "_regenerate_health"))
	add_child(regen_timer)

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
	velocity = velocity.normalized() * speed
	move_and_slide()
	rotate_towards_mouse()
	
	var collision_shape = map_collision.shape as RectangleShape2D
	var half_extents = collision_shape.extents  # Half the size of the rectangle
	var scale = map_collision.global_scale  # Include scaling
	var scaled_extents = half_extents * scale  # Scale the extents

	var map_position = map_collision.global_position

	position.x = clamp(position.x, map_position.x - scaled_extents.x, map_position.x + scaled_extents.x)
	position.y = clamp(position.y, map_position.y - scaled_extents.y, map_position.y + scaled_extents.y)
	
func _regenerate_health():
	if health < max_health:
		health += 1
		health = min(health, max_health)
		health_bar.value = health

func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
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
