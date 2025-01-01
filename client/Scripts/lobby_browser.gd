extends Control

@onready var lobby_list = $ScrollContainer/VBoxContainer

func _ready():
	var lobby_manager = get_node("/root/LobbyManager")
	lobby_manager.connect("lobbies_updated",Callable(self, "_update_lobby_list"))
	lobby_manager.fetch_lobbies()

func _update_lobby_list():
	lobby_list.clear_children() # Utility function to clear old entries
	var lobby_manager = get_node("/root/LobbyManager")
	for lobby in lobby_manager.lobbies:
		var button = Button.new()
		button.text = "%s (%s)" % [lobby["name"], lobby["players"]]
		button.connect("pressed", Callable(self, "_join_lobby", [lobby]))
		lobby_list.add_child(button)

func _join_lobby(lobby):
	# Handle joining the selected lobby
	print("Joining: ", lobby["name"])

func _on_create_lobby_button_pressed():
	# Transition to a new lobby creation scene or send an RPC to create one
	print("Creating new lobby...")
	# Example: RPC call to create a new lobby
	get_tree().change_scene("res://LobbyCreate.tscn")
