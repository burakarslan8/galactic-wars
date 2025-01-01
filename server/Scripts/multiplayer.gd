extends Node

var peer = null
var players_state = {}
var bullets_state = {}

var lobbies = {}
var lobby_id_counter = 1


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

	var is_valid = db_node.verify_user(username, password)
	rpc_id(get_tree().get_multiplayer().get_remote_sender_id(), "receive_login_result", is_valid)

@rpc("any_peer")
func receive_login_result(success: bool):
	if success:
		print("Login successful on server (symmetry placeholder).")
	else:
		print("Invalid credentials on server (symmetry placeholder).")

@rpc("any_peer")
func create_lobby():
	var sender_id = get_tree().get_multiplayer().get_remote_sender_id()
	var lobby_id = lobby_id_counter
	lobby_id_counter += 1

	lobbies[lobby_id] = {"id": lobby_id, "host": sender_id, "players": [sender_id], "max_players": 4}
	print("Lobby created with ID: ", lobby_id, " by Peer: ", sender_id)
	rpc_id(sender_id, "lobby_created", lobby_id)

@rpc("any_peer")
func join_lobby(lobby_id: int):
	var sender_id = get_tree().get_multiplayer().get_remote_sender_id()
	if lobbies.has(lobby_id):
		var lobby = lobbies[lobby_id]
		if lobby["players"].size() < lobby["max_players"]:
			lobby["players"].append(sender_id)
			print("Peer ", sender_id, " joined Lobby ", lobby_id)
			rpc_id(sender_id, "lobby_joined", lobby_id)
		else:
			print("Lobby is full: ", lobby_id)
			rpc_id(sender_id, "lobby_full", lobby_id)
	else:
		print("Lobby not found: ", lobby_id)
		rpc_id(sender_id, "lobby_not_found", lobby_id)

@rpc("any_peer")
func get_lobbies():
	rpc_id(get_tree().get_multiplayer().get_remote_sender_id(), "receive_lobby_list", lobbies.values())

@rpc("any_peer")
func lobby_created(lobby_id: int):
	# Placeholder for symmetry
	print("Lobby created callback on server (placeholder): ", lobby_id)

@rpc("any_peer")
func lobby_joined(lobby_id: int):
	# Placeholder for symmetry
	print("Lobby joined callback on server (placeholder): ", lobby_id)

@rpc("any_peer")
func lobby_full(lobby_id: int):
	print("Lobby full callback on server (placeholder): ", lobby_id)

@rpc("any_peer")
func lobby_not_found(lobby_id: int):
	print("Lobby not found callback on server (placeholder): ", lobby_id)

@rpc("any_peer")
func receive_lobby_list(lobbies: Array):
	print("Receive lobby list callback on server (placeholder).")
