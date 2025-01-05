extends Area2D

@export var lifetime: float = 10.0

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_auto_remove"))
	add_child(timer)
	timer.start()
	
func _on_body_entered(body):
	if body.name == "Player":
		body.call("collect_xp", 1)
		queue_free()

func _auto_remove():
	queue_free()
