extends Node2D

@export var player_scene: PackedScene
@export var town_scene: PackedScene
@export var companha_scene: PackedScene
@export var urco_scene: PackedScene
@export var cross_scene: PackedScene
@export var burleiro_scene: PackedScene
@export var meiga_scene: PackedScene

@export var herb_scene: PackedScene
@export var vacaloura_scene: PackedScene
@export var salt_scene: PackedScene
@export var vasoira_scene: PackedScene
@export var salt_circle_scene: PackedScene

@onready var maze: Labirinto = $Labirinto
@onready var p_cam: PhantomCamera2D = $PhantomCamera2D

@onready var ui: UI = %UI

var player

func _on_labirinto_maze_built(starting_point: Vector2, dead_ends: Array, crossings: Array, item_positions: Array):
	call_deferred("instantiate_entities", starting_point, dead_ends, crossings, item_positions)

func instantiate_entities(starting_point: Vector2, dead_ends: Array, crossings: Array, item_positions: Array):
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
	
	var pos: Array = get_final_item_positions(item_positions, 6)
	for i in range(3):
		var item_position = pos[i]
		var salt : Salt = instantiate_entity(salt_scene, item_position)
		salt.salt_used.connect(_on_salt_used)
	instantiate_entity(vacaloura_scene, pos[3])
	instantiate_entity(vacaloura_scene, pos[4])
	var vasoira: Vasoira = instantiate_entity(vasoira_scene, pos[5])
	
	dead_ends.shuffle()
	if dead_ends.size() > 0:
		var companha: Companha = instantiate_entity(companha_scene, dead_ends[0])
		companha.dead_ends = dead_ends
		companha.player = player
	
	var center = Vector2((maze.MAZE_WIDTH+1)*32, (maze.MAZE_HEIGHT+1)*32)
	var meiga : Meiga = instantiate_entity(meiga_scene, center)
	
	vasoira.used_broom.connect(meiga.player_used_broom)
	
	var total_herbs = 0
	for dead_end in dead_ends:
		if total_herbs < 7:
			var herb: Herb = instantiate_entity(herb_scene, dead_end)
			herb.saved_herb.connect(_add_herb)
			total_herbs += 1
		else:
			var burleiro : Burleiro = instantiate_entity(burleiro_scene, dead_end)
			burleiro.dead_ends = dead_ends
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

func get_final_item_positions(item_positions: Array, number: int) -> Array[Vector2]:
	var final_item_positions: Array[Vector2] = []
	for i in range(number):
		var position = item_positions.pick_random()
		while final_item_positions.has(position):
			position = item_positions.pick_random()
		final_item_positions.append(position)
	return final_item_positions
