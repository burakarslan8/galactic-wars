extends Node

const GAME_WORLD_SCENE = "res://Scenes/GameWorld.tscn"

func _ready():
	var game_world = preload(GAME_WORLD_SCENE).instantiate()
	add_child(game_world)
	game_world.position = Vector2(0, 0)
