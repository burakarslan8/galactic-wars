extends Node2D

@export var inner_radius: float = 1500
@export var outer_radius: float = 1800
@export var spawn_interval: float = 5.0
var stage: int = 1

func _ready():
	var stage_manager = get_parent().get_node("StageManager")
	stage_manager.connect("stage_changed", Callable(self, "_on_stage_changed"))

	var timer = Timer.new()
	timer.name = "SpawnTimer"
	timer.wait_time = spawn_interval
	timer.autostart = false
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
		_spawn_mob()
		
	else:
		print("Error: SpawnTimer not found!")
	
func _spawn_mob():
	print("Spawning mobs for Stage:", stage)
	_spawn_mob_circular()

func _spawn_mob_circular():
	var game = get_parent()
	var player = get_parent().get_node("Player")
	var player_position = Vector2(0,0)
	if player:
		player_position = player.global_position

	var mob_count = 4 + ((stage - 1) / 5) * 2

	for i in range(mob_count):
		var angle = i * (TAU / mob_count)
		var position = player_position + Vector2(cos(angle), sin(angle)) * outer_radius
		var mob = game.spawn_mob(position)
		
		if mob:
			mob.increase_stats((stage - 1) * 8, (stage - 1) * 2, (stage - 1) * 20)
		else:
			print("Error: Spawned mob is invalid or missing properties")
