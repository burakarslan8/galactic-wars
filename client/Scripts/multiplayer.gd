extends Node

const SERVER_ADDRESS: String = "127.0.0.1"
const SERVER_PORT: int = 9000
var peer = null

func _ready():
	connect_to_server()

func connect_to_server():
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(SERVER_ADDRESS, SERVER_PORT)
	if result == OK:
		print("Attempting to connect to server at %s:%d" % [SERVER_ADDRESS, SERVER_PORT])
		multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.connection_failed.connect(_on_connection_failed)
		multiplayer.server_disconnected.connect(_on_server_disconnected)
	else:
		print("Failed to connect to server. Error code: ", result)

func _on_connected_to_server():
	print("Successfully connected to the server.")

func _on_connection_failed():
	print("Failed to connect to the server.")

func _on_server_disconnected():
	print("Disconnected from the server.")

@rpc("any_peer")
func remove_player(peer_id: int):
	var game_world = get_node("/root/Main/GameWorld")
	if game_world:
		game_world.remove_player(peer_id)

@rpc("any_peer")
func update_player_position(peer_id: int, position: Vector2):
	print("Received position update for Peer ID: ", peer_id, " Position: ", position)
	var game_world = get_node("/root/Main/GameWorld")
	if game_world:
		game_world.update_player_position(peer_id, position)

@rpc("any_peer")
func synchronize_position(peer_id: int, position: Vector2):
	var game_world = get_node("/root/Main/GameWorld")
	if game_world:
		game_world.update_player_position(peer_id, position)

@rpc("any_peer")
func update_weapon_rotation(peer_id: int, rotation: float):
	var game_world = get_node("/root/Main/GameWorld")
	if game_world:
		var player = game_world.get_player(peer_id)
		if player and player.character and player.character.weapon:
			player.character.weapon.rotate_towards_remote(rotation)

@rpc("any_peer")
func sync_shoot(peer_id: int, position: Vector2, direction: Vector2):
	var game_world = get_node("/root/Main/GameWorld")
	if game_world:
		var player = game_world.get_player(peer_id)
		if player and player.character and player.character.weapon:
			player.character.weapon.spawn_bullet(position, direction)

@rpc("any_peer")
func sync_bullet_position(peer_id: int, bullet_id: int, position: Vector2):
	var game_world = get_node("/root/Main/GameWorld")
	if game_world:
		game_world.update_bullet_position(bullet_id, position)

@rpc("any_peer")
func register_bullet(peer_id: int, bullet_id: int, position: Vector2, direction: Vector2):
	var game_world = get_node("/root/Main/GameWorld")
	if game_world:
		if bullet_id in game_world.bullets:
			print("Bullet with ID: ", bullet_id, " already exists.")
			return
		game_world.add_bullet(bullet_id, position, direction)

@rpc("any_peer")
func sync_remove_bullet(bullet_id: int):
	var game_world = get_node("/root/Main/GameWorld")
	if game_world:
		game_world.remove_bullet(bullet_id)

@rpc("any_peer")
func handle_register(username: String, email: String, password: String) -> bool:
	print("handle_register called on client (placeholder).")
	return true

@rpc("any_peer")
func handle_login(username: String, password: String) -> bool:
	print("handle_login called on client (placeholder).")
	return true

@rpc("any_peer")
func receive_login_result(success: bool):
	if success:
		get_tree().get_root().get_node("Main").on_login_success()
	else:
		print("Invalid credentials.")

@rpc("any_peer")
func create_lobby():
	# Placeholder for symmetry
	print("Create lobby called on client (placeholder).")

@rpc("any_peer")
func join_lobby(lobby_id: int):
	# Placeholder for symmetry
	print("Join lobby called on client (placeholder).")

@rpc("any_peer")
func get_lobbies():
	print("Get lobbies called on client (placeholder).")

@rpc("any_peer")
func lobby_created(lobby_id: int):
	print("Lobby created successfully with ID: ", lobby_id)

@rpc("any_peer")
func lobby_joined(lobby_id: int):
	print("Successfully joined Lobby ID: ", lobby_id)

@rpc("any_peer")
func lobby_full(lobby_id: int):
	print("Lobby is full: ", lobby_id)

@rpc("any_peer")
func lobby_not_found(lobby_id: int):
	print("Lobby not found: ", lobby_id)

@rpc("any_peer")
func receive_lobby_list(lobbies: Array):
	print("Received lobby list from server: ", lobbies)
	var lobby_browser = get_node("/root/Main/LobbyBrowser")
	if lobby_browser:
		lobby_browser.update_lobbies(lobbies)
	else:
		print("Error: LobbyBrowser node not found!")
