extends Node

@export var spawn_interval: float = 5.0
@export var spawn_radius: float = 1500.0
var player: Node2D = null

func _ready():
	player = get_tree().get_root().get_node("Game/Player")
	
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_spawn_meteors"))
	add_child(timer)

func _spawn_meteors():
	if not player:
		return

	var meteor_scene = preload("res://Scenes/Meteor.tscn")

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var meteor_count = rng.randi_range(1, 1)

	for i in range(meteor_count):
		var angle = rng.randf_range(0, TAU)
		var spawn_position = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_radius

		var meteor = meteor_scene.instantiate()
		meteor.global_position = spawn_position
		meteor.initialize(player.global_position)
		add_child(meteor)
