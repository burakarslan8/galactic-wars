extends Node

var xp = 0
var level = 1

func _ready():
	pass

func spawn_mob(spawn_position : Vector2):
	print("Spawning mob")
	var mob_scene = preload("res://Scenes/Mob.tscn")
	var mob = mob_scene.instantiate()
	add_child(mob)
	
	mob.position = spawn_position

func collect_xp(amount):
	xp += amount
	if xp >= level * 10:
		level_up()

func level_up():
	level += 1

func game_over():
	get_tree().change_scene("res://Scenes/GameOver.tscn")
