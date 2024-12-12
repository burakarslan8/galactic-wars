extends Node2D

var players: Array = []

func add_player(player_id: int, spawn_position: Vector2):
	var player = preload("res://Scenes/Player.tscn").instantiate()
	add_child(player)

	player.set_id(str(player_id))

	players.append(player)

func remove_player(player_id: int):
	for player in players:
		if player.get_id() == str(player_id):
			player.queue_free()
			players.erase(player)
			break

func _ready() -> void:
	add_player(1, Vector2(0,0))
