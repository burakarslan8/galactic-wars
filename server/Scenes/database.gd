extends Node2D

var db : SQLite = null
var db_path := "res://database.db"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db = SQLite.new()
	db.path = db_path
	if db.open_db():
		print("Database connection successful.")
	else:
		print("Failed to connect to the database.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
