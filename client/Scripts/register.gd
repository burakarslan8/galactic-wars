extends Control

signal back_to_login

@onready var username_field = $UsernameInput
@onready var email_field = $EmailInput
@onready var password_field = $PasswordInput
@onready var confirm_password_field = $ConfirmPasswordInput
@onready var register_button = $RegisterButton
@onready var back_button = $BackButton

func _ready():
	register_button.connect("pressed", Callable(self, "_on_register_button_pressed"))
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _on_register_button_pressed():
	var username = username_field.text
	var email = email_field.text
	var password = password_field.text
	var confirm_password = confirm_password_field.text

	if username == "" or email == "" or password == "" or confirm_password == "":
		print("All fields are required!")
		return

	if password != confirm_password:
		print("Passwords do not match!")
		return

	print("Attempting to register...")
	var multiplayer = get_node("/root/Multiplayer")
	var success = multiplayer.rpc_id(1, "handle_register", username, email, password)

	if success:
		print("Registration successful! Returning to login.")
		_on_back_button_pressed()
	else:
		print("Registration failed.")

func _on_back_button_pressed():
	emit_signal("back_to_login")
