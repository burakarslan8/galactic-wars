extends Node2D

func _ready() -> void:
	add_player(Vector2(0, 0))
	

func add_player(spawn_position: Vector2):
	var player = preload("res://Scenes/Player.tscn").instantiate()
	add_child(player)
	player.spawn_character(spawn_position)
