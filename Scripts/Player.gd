extends CharacterBody2D

var speed = 700
var health = 100
var camera: Camera2D = null
var weapon: Weapon = null
@onready var health_bar = $ProgressBar

func _ready() -> void:
	camera = $Camera2D
	if camera:
		print("Camera attached to character")
	health_bar.max_value = health
	health_bar.value = health
	equip_weapon()

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

func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		die()

func die():
	call_deferred("_transition_to_game_over")

func _transition_to_game_over():
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
	queue_free()

func equip_weapon() -> void:
	weapon = preload("res://Scenes/Weapon.tscn").instantiate()
	add_child(weapon)
	weapon.position = Vector2(0, -40)
