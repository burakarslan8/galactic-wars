extends Node

var peer = null
var players_state = {}

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
