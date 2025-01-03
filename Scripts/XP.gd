extends Area2D

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "Player":
		body.get_parent().call("collect_xp", 1)
		queue_free()
