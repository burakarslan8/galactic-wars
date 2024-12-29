extends Node2D

var players: Dictionary = {}

func add_player(peer_id: int, spawn_position: Vector2):
	if peer_id in players:
		print("Player with Peer ID already exists: ", peer_id)
		return

	var player = preload("res://Scenes/Player.tscn").instantiate()
	add_child(player)
	player.name = str(peer_id)
	player.set_id(peer_id)
	player.spawn_character(spawn_position)

	players[peer_id] = player

func remove_player(peer_id: int):
	if peer_id in players:
		players[peer_id].queue_free()
		players.erase(peer_id)
		print("Player removed with Peer ID: ", peer_id)

func update_player_position(peer_id: int, position: Vector2):
	if peer_id in players:
		players[peer_id].character.position = position
		print("Updated position for Peer ID: ", peer_id, " position: ", int(position['x']), ", " , int(position['y']))

func get_player(peer_id: int) -> Node:
	return players.get(peer_id, null)
