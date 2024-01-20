extends Node2D

@export var player_scene: PackedScene
@export var town_scene: PackedScene
@export var companha_scene: PackedScene

@onready var maze: Labirinto = $Labirinto

var player

func _on_labirinto_maze_built(starting_point: Vector2, dead_ends: Array):
	var town = town_scene.instantiate()
	town.position = starting_point
	player = player_scene.instantiate()
	player.position = starting_point
	if dead_ends.size() > 0:
		var companha: Companha = companha_scene.instantiate()
		companha.position = dead_ends[0]
		companha.player = player
		call_deferred("add_child", companha)
	call_deferred("add_child", town)
	call_deferred("add_child", player)
