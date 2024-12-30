extends Node

var peer = null
var players_state = {}
var bullets_state = {}


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

	var rng = RandomNumberGenerator.new()
	var spawn_position = Vector2(rng.randf_range(100, 500), rng.randf_range(100, 500))

	players_state[id] = {"position": spawn_position}

	rpc("broadcast_spawn_player", id, spawn_position)

	for existing_peer_id in players_state.keys():
		if existing_peer_id != id:
			var existing_position = players_state[existing_peer_id]["position"]
			rpc_id(id, "broadcast_spawn_player", existing_peer_id, existing_position)

func _on_peer_disconnected(id: int):
	print("Peer disconnected with ID: ", id)
	players_state.erase(id)
	rpc("remove_player", id)

@rpc("any_peer")
func broadcast_spawn_player(peer_id: int, spawn_position: Vector2):
	print("Spawning player for Peer ID: ", peer_id, " at position: ", spawn_position)

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
	rpc("update_weapon_rotation", peer_id, rotation)

@rpc("any_peer")
func sync_shoot(peer_id: int, position: Vector2, direction: Vector2):
	rpc("sync_shoot", peer_id, position, direction)

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
