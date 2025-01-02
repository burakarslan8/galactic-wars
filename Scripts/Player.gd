extends CharacterBody2D

var speed = 500
var health = 100
var camera: Camera2D = null
var weapon: Weapon = null

func _ready() -> void:
	camera = $Camera2D
	if camera:
		print("Camera attached to character")
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
	if health <= 0:
		die()

func die():
	queue_free()
	get_tree().change_scene("res://Scenes/GameOver.tscn")

func equip_weapon() -> void:
	weapon = preload("res://Scenes/Weapon.tscn").instantiate()
	add_child(weapon)
	weapon.position = Vector2(0, -40)
