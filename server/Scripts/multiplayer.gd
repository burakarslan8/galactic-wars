extends Node

var peer = null
var players_state = {}
var bullets_state = {}

var lobbies = {}
var lobby_id_counter = 1
var peer_to_user = {}


func _ready():
	start_server()

func start_server():
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(9000, 10)
	if result == OK:
		print("Server started on port 9000")
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	else:
		print("Failed to start server. Error code: ", result)

func _on_peer_connected(id: int):
	print("Peer connected with ID: ", id)

func _on_peer_disconnected(id: int):
	print("Peer disconnected with ID: ", id)
	players_state.erase(id)
	rpc("remove_player", id)
	if peer_to_user.has(id):
		print("Removing mapping for Peer ID: ", id, " (User ID: ", peer_to_user[id], ")")
		peer_to_user.erase(id)

@rpc("any_peer")
func remove_player(peer_id: int):
	print("Removing player for Peer ID: ", peer_id)

@rpc("any_peer")
func update_player_position(peer_id: int, position: Vector2):
	if peer_id in players_state:
		players_state[peer_id]["position"] = position
		rpc("synchronize_position", peer_id, position)

@rpc("any_peer")
func synchronize_position(peer_id: int, position: Vector2):
	print("Synchronizing position for Peer ID: ", peer_id, " to position: ", position)

@rpc("any_peer")
func update_weapon_rotation(peer_id: int, rotation: float):
	rpc_id(0, "update_weapon_rotation", peer_id, rotation)

@rpc("any_peer")
func sync_shoot(peer_id: int, position: Vector2, direction: Vector2):
	rpc_id(0, "sync_shoot", peer_id, position, direction)

@rpc("any_peer")
func register_bullet(peer_id: int, bullet_id: int, position: Vector2, direction: Vector2):
	bullets_state[bullet_id] = {"peer_id": peer_id, "position": position, "direction": direction}

@rpc("any_peer")
func sync_bullet_position(peer_id: int, bullet_id: int, position: Vector2):
	if bullet_id in bullets_state:
		bullets_state[bullet_id]["position"] = position

@rpc("any_peer")
func sync_remove_bullet(peer_id: int, bullet_id: int):
	if bullet_id in bullets_state:
		bullets_state.erase(bullet_id)
		rpc("sync_remove_bullet", bullet_id)

func _process(delta: float) -> void:
	handle_bullet_collisions()

func handle_bullet_collisions():
	for bullet_id in bullets_state.keys():
		var bullet_info = bullets_state[bullet_id]
		var bullet_position = bullet_info["position"]

		for peer_id in players_state.keys():
			if bullet_info["peer_id"] == peer_id:
				continue

			var player_position = players_state[peer_id]["position"]
			if bullet_position.distance_to(player_position) < 20:
				print("Bullet ", bullet_id, " hit Player ", peer_id)
				apply_damage_to_player(peer_id, bullet_info["peer_id"])
				bullets_state.erase(bullet_id)
				break

func apply_damage_to_player(target_peer_id: int, shooter_peer_id: int):
	if target_peer_id in players_state:
		var current_health = players_state[target_peer_id].get("health", 100)
		current_health -= 10
		players_state[target_peer_id]["health"] = current_health

		print("Player ", target_peer_id, " health: ", current_health)

		if current_health <= 0:
			print("Player ", target_peer_id, " was eliminated by Player ", shooter_peer_id)
			rpc("remove_player", target_peer_id)
			players_state.erase(target_peer_id)

@rpc("any_peer")
func handle_register(username: String, email: String, password: String) -> bool:
	var db_node = Database
	if db_node and db_node.register_user(username, email, password):
		print("Registration successful for: ", username)
		return true
	else:
		print("Failed to register user: ", username)
		return false

@rpc("any_peer")
func handle_login(username: String, password: String):
	var db_node = Database
	if not db_node:
		print("Database autoload not found.")
		rpc_id(get_tree().get_multiplayer().get_remote_sender_id(), "receive_login_result", false)
		return

	var user_id = db_node.get_user_id(username, password)
	if user_id > 0:
		var peer_id = get_tree().get_multiplayer().get_remote_sender_id()
		peer_to_user[peer_id] = user_id
		print("Login successful for user: ", username, " (User ID: ", user_id, ", Peer ID: ", peer_id, ")")
		rpc_id(peer_id, "receive_login_result", true)
	else:
		print("Login failed for user: ", username)
		rpc_id(get_tree().get_multiplayer().get_remote_sender_id(), "receive_login_result", false)

@rpc("any_peer")
func receive_login_result(success: bool):
	if success:
		print("Login successful on server (symmetry placeholder).")
	else:
		print("Invalid credentials on server (symmetry placeholder).")

@rpc("any_peer")
func create_lobby():
	var peer_id = get_tree().get_multiplayer().get_remote_sender_id()
	var user_id = get_user_id_from_peer(peer_id)
	var username = Database.get_username_by_id(user_id)

	var lobby_id = lobby_id_counter
	lobby_id_counter += 1

	lobbies[lobby_id] = {
		"id": lobby_id,
		"host": user_id,
		"host_username": username,
		"players": [user_id],
		"max_players": 4
	}

	print("Lobby created with ID: ", lobby_id, " by User: ", username, " (User ID: ", user_id, ")")
	rpc_id(peer_id, "lobby_created", lobby_id)

@rpc("any_peer")
func join_lobby(lobby_id: int):
	var peer_id = get_tree().get_multiplayer().get_remote_sender_id()
	var user_id = get_user_id_from_peer(peer_id)
	if user_id < 0:
		rpc_id(peer_id, "lobby_join_failed", "User not logged in.")
		return

	if lobbies.has(lobby_id):
		var lobby = lobbies[lobby_id]
		if lobby["players"].size() < lobby["max_players"]:
			lobby["players"].append(user_id)
			rpc_id(peer_id, "joined_lobby", lobby_id, lobby["players"])
			broadcast_lobby_update(lobby_id)
		else:
			rpc_id(peer_id, "lobby_full", lobby_id)
	else:
		rpc_id(peer_id, "lobby_not_found", lobby_id)

@rpc("any_peer")
func leave_lobby(lobby_id: int):
	var peer_id = get_tree().get_multiplayer().get_remote_sender_id()
	var user_id = get_user_id_from_peer(peer_id)
	if lobbies.has(lobby_id) and user_id in lobbies[lobby_id]["players"]:
		lobbies[lobby_id]["players"].erase(user_id)
		rpc_id(peer_id, "left_lobby", lobby_id)
		broadcast_lobby_update(lobby_id)

		if lobbies[lobby_id]["players"] == []:
			lobbies.erase(lobby_id)

func broadcast_lobby_update(lobby_id: int):
	if lobbies.has(lobby_id):
		var lobby = lobbies[lobby_id]
		rpc("update_lobby_users", lobby_id, lobby["players"])

@rpc("any_peer")
func get_lobbies():
	var lobby_data = []
	for lobby in lobbies.values():
		lobby_data.append({
			"id": lobby["id"],
			"host_username": lobby.get("host_username", "Unknown"),
			"players": lobby["players"],
			"max_players": lobby["max_players"]
		})
	rpc_id(get_tree().get_multiplayer().get_remote_sender_id(), "receive_lobby_list", lobby_data)

func get_user_id_from_peer(peer_id: int) -> int:
	if peer_to_user.has(peer_id):
		return peer_to_user[peer_id]
	return -1

func get_peer_id_from_user(user_id: int) -> int:
	for peer_id in peer_to_user.keys():
		if peer_to_user[peer_id] == user_id:
			return peer_id
	return -1

@rpc("any_peer")
func joined_lobby(lobby_id: int, users: Array):
	print("Joined lobby: ", lobby_id)
	get_node("/root/Main").go_to_lobby(lobby_id, users)

@rpc("any_peer")
func lobby_created(lobby_id: int):
	print("Lobby created successfully with ID: ", lobby_id)
	var multiplayer = get_node("/root/Multiplayer")
	multiplayer.rpc_id(1, "join_lobby", lobby_id)  # Automatically join after creating

@rpc("any_peer")
func update_lobby_users(lobby_id: int, users: Array):
	print("Lobby %d user list updated: " % lobby_id, users)
	var lobby_scene = get_node("/root/Main/Lobby")
	if lobby_scene:
		lobby_scene.update_lobby(lobby_id, users)
	else:
		print("Lobby scene not found.")

@rpc("any_peer")
func left_lobby(lobby_id: int):
	print("Left lobby: ", lobby_id)
	get_node("/root/Main").go_to_lobby_browser()

@rpc("any_peer")
func receive_lobby_list(lobbies: Array):
	print("Received lobby list from server: ", lobbies)
	var lobby_browser = get_node("/root/Main/LobbyBrowser")
	if lobby_browser:
		lobby_browser.update_lobbies(lobbies)
	else:
		print("LobbyBrowser node not found!")
