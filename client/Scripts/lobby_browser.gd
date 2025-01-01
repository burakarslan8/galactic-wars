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
	button.text = "%s (%s)" % [lobby_data["id"], lobby_data["players"]]
	button.connect("pressed", Callable(self, "_on_lobby_selected").bind(lobby_data))
	lobby_list.add_child(button)

# When a lobby is selected
func _on_lobby_selected(lobby_data):
	print("Joining lobby: ", lobby_data["id"])
	# Call server logic to join the lobby
	var multiplayer = get_node("/root/Multiplayer")
	multiplayer.rpc_id(1, "join_lobby", lobby_data["id"])

# When "Create Lobby" is pressed
func _on_create_lobby_pressed():
	print("Creating a new lobby...")
	var multiplayer = get_node("/root/Multiplayer")
	multiplayer.rpc_id(1, "create_lobby")

# When "Refresh" is pressed
func _on_refresh_pressed():
	print("Refreshing lobby list...")
	fetch_lobbies()
