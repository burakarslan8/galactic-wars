extends Node

@export var initial_stage_duration: float = 5.0
@export var stage_duration: float = 20.0
@export var initial_spawn_interval: float = 5.0
@export var spawn_interval_decrement: float = 0.5

@onready var stage_label = get_parent().get_node("GUI/StageLabel")
@onready var game = get_parent()

signal stage_changed(new_stage: int, spawn_interval: float)

var current_stage: int = 0
var spawn_interval: float = initial_spawn_interval
var last_stage_time: float = 0.0

func _ready():
	await get_tree().create_timer(initial_stage_duration).timeout
	increment_stage()

func _process(delta: float) -> void:
	var elapsed_time = game.get_elapsed_time()
	if elapsed_time - last_stage_time >= stage_duration:
		increment_stage()
		last_stage_time = elapsed_time

func increment_stage():
	current_stage += 1

	if current_stage % 5 == 0:
		spawn_interval = max(0.5, spawn_interval - spawn_interval_decrement)

	if stage_label:
		stage_label.text = "STAGE " + str(current_stage)
		stage_label.show()
		
		call_deferred("_on_stage_start")

func _on_stage_start():
	await get_tree().create_timer(2.0).timeout
	stage_label.hide()

	emit_signal("stage_changed", current_stage, spawn_interval)
	print("Stage progressed to:", current_stage)
