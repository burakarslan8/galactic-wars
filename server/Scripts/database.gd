extends Node2D

var db: SQLite = null
var db_path := "res://database.db"

func _ready() -> void:
	db = SQLite.new()
	db.verbosity_level = SQLite.VERBOSE
	db.path = db_path
	if db.open_db():
		print("Database connection successful.")
		initialize_user_table()
	else:
		print("Failed to connect to the database.")

func initialize_user_table() -> void:
	var query = "CREATE TABLE IF NOT EXISTS user (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, email TEXT UNIQUE, password TEXT);"
	var result = db.query(query)
	if result:
		print("User table initialized or already exists.")
	else:
		print("Failed to initialize user table: ", db.get_last_error_message())

func register_user(username: String, email: String, password: String) -> bool:
	var query = "INSERT INTO user (username, password, email) VALUES ('%s', '%s', '%s');" % [username, password, email]
	var result = db.query(query)
	if result:
		print("User registered successfully: ", username)
		return true
	else:
		print("Registration failed for user: ", username, " - Error: ", db.error_message)
		return false

func verify_user(username: String, password: String) -> bool:
	var query = "SELECT password FROM user WHERE username = '%s';" % username
	var result = db.query(query)

	if result:
		var rows = db.query_result
		if rows.size() > 0:
			var stored_password = rows[0]["password"]
			if stored_password == password:
				print("Login successful for user: ", username)
				return true
			else:
				print("Password mismatch for user: ", username)
		else:
			print("No user found with username: ", username)
	else:
		print("Database query failed: ", db.error_message)

	return false

func get_user_id(username: String, password: String) -> int:
	var query = "SELECT id, password FROM user WHERE username = '%s';" % username
	var result = db.query(query)

	if result:
		var rows = db.query_result
		if rows.size() > 0:
			var stored_password = rows[0]["password"]
			if stored_password == password:
				var user_id = rows[0]["id"]
				print("User ID retrieved for username: ", username, " - ID: ", user_id)
				return user_id
			else:
				print("Password mismatch for username: ", username)
		else:
			print("No user found with username: ", username)
	else:
		print("Failed to retrieve user ID: ", db.error_message)

	return -1

func get_username_by_id(user_id: int) -> String:
	var query = "SELECT username FROM user WHERE id = %d;" % user_id
	var result = db.query(query)

	if result:
		var rows = db.query_result
		if rows.size() > 0:
			var username = rows[0]["username"]
			print("Username retrieved for User ID: ", user_id, " - Username: ", username)
			return username
		else:
			print("No user found with User ID: ", user_id)
	else:
		print("Database query failed: ", db.error_message)

	return ""
