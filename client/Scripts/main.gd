extends Node

var login_scene = preload("res://Scenes/Login.tscn")
var register_scene = preload("res://Scenes/Register.tscn")
var lobby_scene = preload("res://Scenes/LobbyBrowser.tscn")

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


func on_login_success():
	print("Login successful, loading lobby...")
	_load_scene(lobby_scene)

func on_register_pressed():
	print("Navigating to register scene...")
	_load_scene(register_scene)

func on_back_to_login():
	print("Returning to login scene...")
	_load_scene(login_scene)
