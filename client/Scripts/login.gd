extends Control

signal login_success
signal register_pressed

@onready var username_field = $UsernameInput
@onready var password_field = $PasswordInput
@onready var login_button = $LoginButton
@onready var register_link = $RegisterLink

func _ready():
	login_button.connect("pressed", Callable(self, "_on_login_button_pressed"))
	register_link.connect("pressed", Callable(self, "_on_register_button_pressed"))

func _on_login_button_pressed():
	var username = username_field.text
	var password = password_field.text

	if username == "" or password == "":
		print("Username or password is empty!")
		return

	print("Attempting to log in...")
	var multiplayer = get_node("/root/Multiplayer")
	multiplayer.rpc_id(1, "handle_login", username, password)


func _on_register_button_pressed():
	emit_signal("register_pressed")
