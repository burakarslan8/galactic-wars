extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

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
		queue_free()
