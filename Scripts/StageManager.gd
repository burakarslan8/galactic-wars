extends Node

@export var initial_stage_duration: float = 5.0  # Duration of the first stage in seconds
@export var stage_duration: float = 20.0         # Duration of subsequent stages
@export var initial_spawn_interval: float = 5.0  # Starting spawn interval
@export var spawn_interval_decrement: float = 0.5  # Decrease in spawn interval every 5 stages

@onready var stage_label = get_parent().get_node("Player/Camera2D/StageLabel")

signal stage_changed(new_stage: int, spawn_interval: float)

var current_stage: int = 0
var elapsed_time: float = 0.0
var spawn_interval: float = initial_spawn_interval

func _ready():
	await get_tree().create_timer(initial_stage_duration).timeout
	increment_stage()

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= stage_duration:
		elapsed_time = 0.0
		increment_stage()

func increment_stage():
	current_stage += 1

	if current_stage % 5 == 0:
		spawn_interval = max(0.5, spawn_interval - spawn_interval_decrement)

	if stage_label:
		stage_label.text = "STAGE " + str(current_stage)
		stage_label.show()
		await get_tree().create_timer(2.0).timeout
		stage_label.hide()

	emit_signal("stage_changed", current_stage, spawn_interval)
	print("Stage progressed to:", current_stage)
