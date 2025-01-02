extends Node

var login_scene = preload("res://Scenes/Login.tscn")
var register_scene = preload("res://Scenes/Register.tscn")
var lobby_browser_scene = preload("res://Scenes/LobbyBrowser.tscn")
var lobby_scene = preload("res://Scenes/Lobby.tscn")

var current_scene

func _ready():
	_load_scene(login_scene)

func _load_scene(scene):
	if current_scene:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	add_child(current_scene)

	if scene == login_scene:
		current_scene.connect("login_success", Callable(self, "on_login_success"))
		current_scene.connect("register_pressed", Callable(self, "on_register_pressed"))
	elif scene == register_scene:
		current_scene.connect("back_to_login", Callable(self, "on_back_to_login"))
	elif scene == lobby_scene:
		current_scene.connect("leave_lobby", Callable(self, "on_leave_lobby"))

func on_login_success():
	print("Login successful, loading lobby...")
	_load_scene(lobby_browser_scene)

func on_register_pressed():
	print("Navigating to register scene...")
	_load_scene(register_scene)

func on_back_to_login():
	print("Returning to login scene...")
	_load_scene(login_scene)

func go_to_lobby(lobby_id: int, users: Array):
	print("Entering lobby: ", lobby_id)
	_load_scene(lobby_scene)
	current_scene.update_lobby(lobby_id, users)

func go_to_lobby_browser():
	print("Returning to lobby browser...")
	_load_scene(lobby_browser_scene)

func on_leave_lobby(lobby_id: int):
	print("Leaving lobby: ", lobby_id)
	var multiplayer = get_node("/root/Multiplayer")
	multiplayer.rpc_id(1, "leave_lobby", lobby_id)
	go_to_lobby_browser()
