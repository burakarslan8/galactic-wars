extends Node

func _ready():
	print("Server logic initialized.")

func on_player_connected(peer_id: int):
	print("Player connected with ID: ", peer_id)

func on_player_disconnected(peer_id: int):
	print("Player disconnected with ID: ", peer_id)
