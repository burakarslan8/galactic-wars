extends Node2D

@export var inner_radius: float = 1500
@export var outer_radius: float = 1800
@export var spawn_interval: float = 10.0
var stage: int = 0

func _ready():
	var stage_manager = get_parent().get_node("StageManager")
	stage_manager.connect("stage_changed", Callable(self, "_on_stage_changed"))

	var timer = Timer.new()
	timer.name = "SpawnTimer"
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_spawn_mob"))
	add_child(timer)
	
func _on_stage_changed(new_stage: int, new_spawn_interval: float):
	stage = new_stage
	spawn_interval = new_spawn_interval
	print("Spawn interval updated to:", spawn_interval)
	var timer = get_node("SpawnTimer")
	if timer:
		timer.wait_time = spawn_interval
		timer.start()
	else:
		print("Error: SpawnTimer not found!")

	_spawn_mob()
	
func _spawn_mob():
	print("Spawning mobs for Stage:", stage)
	_spawn_mob_circular()

func _spawn_mob_circular():
	var game = get_parent()
	var player_position = get_parent().get_node("Player").global_position

	var mob_count = 6
	for i in range(mob_count):
		var angle = i * (TAU / mob_count)
		var position = player_position + Vector2(cos(angle), sin(angle)) * outer_radius
		var mob = game.spawn_mob(position)
		
		if mob and mob.has_method("set_stats"):
			mob.set_stats((stage - 1) * 10, (stage - 1) * 5, (stage - 1) * 25)
		else:
			print("Error: Spawned mob is invalid or missing properties")
