extends Node2D

var players: Dictionary = {}
var bullets = {}

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

func get_player(peer_id: int) -> Node:
	return players.get(peer_id, null)

func add_bullet(bullet_id: int, position: Vector2, direction: Vector2):
	if bullet_id in bullets:
		print("Bullet with ID already exists: ", bullet_id)
		return

	var bullet = preload("res://Scenes/Bullet.tscn").instantiate()
	add_child(bullet)
	bullet.name = str(bullet_id)
	bullet.global_position = position
	bullet.set_direction(direction)

	bullets[bullet_id] = bullet
	print("Bullet added with ID: ", bullet_id)

func update_bullet_position(bullet_id: int, position: Vector2):
	if bullet_id in bullets:
		bullets[bullet_id].position = position
	else:
		print("Bullet with ID: ", bullet_id, " does not exist.")

func remove_bullet(bullet_id: int):
	if bullet_id in bullets:
		bullets[bullet_id].queue_free()
		bullets.erase(bullet_id)
		print("Bullet removed with ID: ", bullet_id)
