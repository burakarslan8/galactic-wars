extends Node

var xp = 0
var level = 1

func _ready():
	spawn_mob()

func spawn_mob():
	print("Spawning mob")
	var mob_scene = preload("res://Scenes/Mob.tscn")
	var mob = mob_scene.instantiate()
	add_child(mob)
	var rng = RandomNumberGenerator.new()
	mob.position = Vector2(rng.randf_range(0, 800), rng.randf_range(0, 600))

func collect_xp(amount):
	xp += amount
	if xp >= level * 10:
		level_up()

func level_up():
	level += 1

func game_over():
	get_tree().change_scene("res://Scenes/GameOver.tscn")
