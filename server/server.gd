extends Node

const PORT: int = 9000
const MAX_PLAYERS: int = 10


func _ready():
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(PORT, MAX_PLAYERS)
	
	if result == OK:
		print("Server started on port ", PORT)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	else:
		print("Failed to start server. Error code: ", result)

func _on_peer_connected(id: int):
	print("Peer connected with ID: ", id)

func _on_peer_disconnected(id: int):
	print("Peer disconnected with ID: ", id)
