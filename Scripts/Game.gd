extends Node

var level = 1

func _ready():
	var stage_manager = $StageManager
	stage_manager.connect("stage_changed", Callable(self, "_on_stage_changed"))

func _on_stage_changed(new_stage: int, spawn_interval: float):
	print("Game advanced to Stage:", new_stage)

func spawn_mob(spawn_position: Vector2) -> Node:
	print("Spawning mob")
	var mob_scene = preload("res://Scenes/Mob.tscn")
	var mob = mob_scene.instantiate()
	add_child(mob)
	mob.position = spawn_position
	return mob

func game_over():
	get_tree().change_scene("res://Scenes/GameOver.tscn")
