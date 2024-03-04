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

@export var max_herbs: int = 7

@onready var maze: Labirinto = $Labirinto

signal created_herbs(herbs: Array)

func _on_labirinto_maze_built(starting_point: Vector2, dead_ends: Array, crossings: Array, item_positions: Array):
	call_deferred("instantiate_entities", starting_point, dead_ends, crossings, item_positions)

func instantiate_entities(starting_point: Vector2, dead_ends: Array, crossings: Array, item_positions: Array):
	dead_ends.remove_at(dead_ends.find(starting_point))
	var town = instantiate_entity(town_scene, starting_point)
	#player = instantiate_entity(player_scene, starting_point)
	var player
	player = $Player1
	player.global_position = starting_point + Vector2.LEFT*8
	player.town = town
	player.velocity = Vector2.ZERO
	player = $Player2
	player.global_position = starting_point + Vector2.RIGHT*8
	player.town = town
	player.velocity = Vector2.ZERO
	
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
	
	var center = Vector2((maze.MAZE_WIDTH+1)*32, (maze.MAZE_HEIGHT+1)*32)
	var meiga : Meiga = instantiate_entity(meiga_scene, center)
	
	vasoira.used_broom.connect(meiga.player_used_broom)
	
	var total_herbs = 0
	var herbs: Array = []
	for dead_end in dead_ends:
		if herbs.size() < max_herbs:
			var herb: Herb = instantiate_entity(herb_scene, dead_end)
			herbs.append(herb)
			herb.sprite.frame = total_herbs
			total_herbs += 1
		else:
			var burleiro : Burleiro = instantiate_entity(burleiro_scene, dead_end)
			burleiro.dead_ends = dead_ends
	created_herbs.emit(herbs)


func instantiate_entity(entity_scene: PackedScene, entity_position: Vector2) -> Node:
	var entity = entity_scene.instantiate()
	entity.position = entity_position
	add_child(entity)
	return entity

func _on_salt_used(position_salt : Vector2):
	instantiate_entity(salt_circle_scene, position_salt)

func get_final_item_positions(item_positions: Array, number: int) -> Array[Vector2]:
	var final_item_positions: Array[Vector2] = []
	for i in range(number):
		var item_position = item_positions.pick_random()
		while final_item_positions.has(item_position):
			item_position = item_positions.pick_random()
		final_item_positions.append(item_position)
	return final_item_positions

