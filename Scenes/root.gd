extends Node2D

@export var player_scene: PackedScene
@export var town_scene: PackedScene
@export var companha_scene: PackedScene
@export var urco_scene: PackedScene
@export var cross_scene: PackedScene
@export var burleiro_scene: PackedScene

@export var herb_scene: PackedScene
@export var vacaloura_scene: PackedScene
@export var salt_scene: PackedScene
@export var salt_circle_scene: PackedScene

@onready var maze: Labirinto = $Labirinto
@onready var p_cam: PhantomCamera2D = $PhantomCamera2D

@onready var ui: UI = %UI

var player

func _on_labirinto_maze_built(starting_point: Vector2, dead_ends: Array, crossings: Array):
	call_deferred("instantiate_entities", starting_point, dead_ends, crossings)

func instantiate_entities(starting_point: Vector2, dead_ends: Array, crossings: Array):
	dead_ends.remove_at(dead_ends.find(starting_point))
	var town = instantiate_entity(town_scene, starting_point)
	#player = instantiate_entity(player_scene, starting_point)
	player = $Player1
	player.position = starting_point
	player.town = town
	var crosses = []
	for crossing in crossings:
		crosses.append(instantiate_entity(cross_scene, crossing))
	if crossings.size() > 1:
		var urco = instantiate_entity(urco_scene, crossings.pick_random())
		urco.crossings = crossings
	dead_ends.shuffle()
	if dead_ends.size() > 0:
		var companha: Companha = instantiate_entity(companha_scene, dead_ends[0])
		companha.dead_ends = dead_ends
		companha.player = player
	var total_herbs = 0
	var it = 0
	for dead_end in dead_ends:
		if total_herbs < 1:
			var herb: Herb = instantiate_entity(herb_scene, dead_end)
			herb.saved_herb.connect(_add_herb)
			total_herbs += 1
		else:
			match it:
				0:
					var salt : Salt = instantiate_entity(salt_scene, dead_end)
					salt.salt_used.connect(_on_salt_used)
				1:
					instantiate_entity(vacaloura_scene, dead_end)
				2:
					var burleiro : Burleiro = instantiate_entity(burleiro_scene, dead_end)
					burleiro.dead_ends = dead_ends
			it = (it + 1) % 3
	ui.set_herb_score(0, total_herbs)

func instantiate_entity(entity_scene: PackedScene, entity_position: Vector2) -> Node:
	var entity = entity_scene.instantiate()
	entity.position = entity_position
	add_child(entity)
	return entity

func _add_herb():
	ui.add_herb_score(1)

func _on_salt_used(position_salt : Vector2):
	instantiate_entity(salt_circle_scene, position_salt)
