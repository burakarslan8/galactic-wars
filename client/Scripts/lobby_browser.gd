extends Control

@onready var lobby_list = $ScrollContainer/VBoxContainer
@onready var create_lobby_button = $CreateLobbyButton
@onready var refresh_button = $RefreshButton

func _ready():
	create_lobby_button.connect("pressed", Callable(self, "_on_create_lobby_pressed"))
	refresh_button.connect("pressed", Callable(self, "_on_refresh_pressed"))
	fetch_lobbies()

func fetch_lobbies():
	print("Requesting lobbies from server...")
	var multiplayer = get_node("/root/Multiplayer")
	if multiplayer:
		multiplayer.rpc_id(1, "get_lobbies")
	else:
		print("Error: Multiplayer node not found!")

func update_lobbies(lobbies: Array):
	print("Updating lobby browser with lobbies: ", lobbies)
	for child in lobby_list.get_children():
		child.queue_free()

	for lobby in lobbies:
		add_lobby_entry(lobby)

func add_lobby_entry(lobby_data):
	print("Adding lobby to UI: ", lobby_data)
	var button = Button.new()
	button.text = "Lobby ID: %s | Host: %s | Players: %s/%s" % [
		str(lobby_data["id"]),
		str(lobby_data.get("host_username", "Unknown")),
		str(lobby_data["players"].size()),
		str(lobby_data["max_players"])
	]
	button.connect("pressed", Callable(self, "_on_lobby_selected").bind(lobby_data))
	lobby_list.add_child(button)

func _on_lobby_selected(lobby_data):
	print("Joining lobby: ", lobby_data["id"])
	var multiplayer = get_node("/root/Multiplayer")
	multiplayer.rpc_id(1, "join_lobby", lobby_data["id"])

func _on_create_lobby_pressed():
	print("Creating a new lobby...")
	var multiplayer = get_node("/root/Multiplayer")
	multiplayer.rpc_id(1, "create_lobby")

func _on_refresh_pressed():
	print("Refreshing lobby list...")
	fetch_lobbies()
