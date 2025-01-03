extends Node2D

@export var spawn_area_min: Vector2 = Vector2(-1000, 1000)
@export var spawn_area_max: Vector2 = Vector2(1000, -1000)

@export var spawn_interval: float = 2.0

func _ready():
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_spawn_mob"))
	add_child(timer)

func _spawn_mob():
	var game = get_parent()
	game.spawn_mob(_get_random_spawn_position())

func _get_random_spawn_position() -> Vector2:
	var rng = RandomNumberGenerator.new()
	return Vector2(
		rng.randf_range(spawn_area_min.x, spawn_area_max.x),
		rng.randf_range(spawn_area_min.y, spawn_area_max.y)
	)
