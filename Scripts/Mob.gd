extends Area2D

var speed = 500
var player = null

func _ready():
	player = get_parent().get_node("Player")

func _process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * speed * delta

func _on_mob_destroyed():
	var xp_drop = preload("res://Scenes/XP.tscn").instantiate()
	xp_drop.position = global_position
	get_parent().add_child(xp_drop)
	queue_free()
