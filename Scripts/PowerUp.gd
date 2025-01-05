extends Area2D

@export var duration: float = 5.0
@export var effect_type: String
@export var effect_value: float
@export var lifetime: float = 10.0

func _ready():
	add_to_group("PowerUps")
	self.body_entered.connect(_on_body_entered)
	
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_auto_remove"))
	add_child(timer)
	timer.start()
	
func _on_body_entered(body):
	if body.name == "Player":
		apply_effect(body)
		queue_free()

func apply_effect(player):
	match effect_type:
		"shield":
			if player.has_method("activate_shield"):
				player.activate_shield(duration)
		"damage":
			if player.has_method("boost_damage"):
				player.boost_damage(effect_value, duration)
		"speed":
			if player.has_method("boost_speed"):
				player.boost_speed(effect_value, duration)

func _auto_remove():
	queue_free()
