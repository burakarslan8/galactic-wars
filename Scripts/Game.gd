extends Node

var score: int = 0
var displayed_score: int = 0
@onready var score_label = $GUI/ScoreLabel
var elapsed_time: float = 0.0

func _ready():
	var stage_manager = $StageManager
	stage_manager.connect("stage_changed", Callable(self, "_on_stage_changed"))
	update_score_label()

func _process(delta):
	elapsed_time += delta

	if displayed_score < score:
		displayed_score += 1
		update_score_label()

	add_score(1)

func add_score(amount: int):
	score += amount
	update_score_label()

func update_score_label():
	if score_label:
		score_label.text = "SCORE: " + str(score)

func _on_stage_changed(new_stage: int, spawn_interval: float):
	print("Game advanced to Stage:", new_stage)

func spawn_mob(spawn_position: Vector2) -> Node:
	print("Spawning mob")
	var mob_scene = preload("res://Scenes/Mob.tscn")
	var mob = mob_scene.instantiate()
	add_child(mob)
	mob.position = spawn_position
	
	if mob.has_signal("died"):
		mob.connect("died", Callable(self, "_on_mob_killed"))
	return mob

func _on_mob_killed(killed_by_player: bool):
	if killed_by_player:
		add_score(100)

func game_over():
	var game_over_panel = $GUI/GameOver
	game_over_panel.show_game_over(score)


func get_elapsed_time() -> float:
	return elapsed_time
