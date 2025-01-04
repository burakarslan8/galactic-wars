extends Control

@onready var game_over_label = $Panel/GameOverLabel
@onready var score_label = $Panel/ScoreLabel
@onready var restart_button = $RestartButton
@onready var quit_button = $QuitButton

var final_score: int = 0

func _ready():
	visible = false
	restart_button.pressed.connect(_on_RestartButton_pressed)
	quit_button.pressed.connect(_on_QuitButton_pressed)

func show_game_over(score: int):
	final_score = score
	score_label.text = "SCORE: " + str(final_score)
	visible = true

	get_tree().paused = true

func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
