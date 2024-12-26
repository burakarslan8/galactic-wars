extends Node

const GAME_WORLD_SCENE = "res://Scenes/GameWorld.tscn"
const SERVER_ADDRESS: String = "192.168.1.111"
const SERVER_PORT: int = 9000

func _ready() -> void:
	
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(SERVER_ADDRESS, SERVER_PORT)
	
	if result == OK:
		print("Attempting to connect to server at %s:%d" % [SERVER_ADDRESS, SERVER_PORT])
		multiplayer.multiplayer_peer = peer
		
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.connection_failed.connect(_on_connection_failed)
		multiplayer.server_disconnected.connect(_on_server_disconnected)
	else:
		print("Failed to create client. Error code: ", result)

	var game_world = preload(GAME_WORLD_SCENE).instantiate()
	add_child(game_world)

	game_world.position = Vector2(0, 0)

func _on_connected_to_server():
	print("Successfully connected to the server.")

func _on_connection_failed():
	print("Failed to connect to the server.")

func _on_server_disconnected():
	print("Disconnected from the server.")
	
