extends Node

signal lobbies_updated

var lobbies = []

func fetch_lobbies():
	lobbies = [
		{"name": "Lobby 1", "players": "2/4"},
		{"name": "Lobby 2", "players": "1/4"},
	]
	emit_signal("lobbies_updated")
