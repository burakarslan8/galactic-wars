extends CharacterBody2D

var speed = 700
var health = 100
var xp = 0
var level = 1
var camera: Camera2D = null
var weapon: Weapon = null
@onready var health_bar = get_parent().get_node("GUI/HealthBar")
@onready var xp_bar = get_parent().get_node("GUI/XPBar")
@onready var level_label = get_parent().get_node("GUI/LevelLabel")

func _ready() -> void:
	camera = $Camera2D
	if camera:
		print("Camera attached to character")
	health_bar.max_value = health
	health_bar.value = health
	xp_bar.max_value = 10
	xp_bar.value = xp % 10
	level_label.text = "LEVEL: " + str(level)

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

func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		die()

func die():
	call_deferred("_transition_to_game_over")

func _transition_to_game_over():
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

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
