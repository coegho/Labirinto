extends TileMap

class_name Labirinto

const MAZE_WIDTH: int = 8
const MAZE_HEIGHT: int = 8

@onready var astar_node: AStarGrid2D = AStarGrid2D.new()

var road_cells: Array[Vector2i]

signal maze_built(starting_point: Vector2, dead_ends: Array[Vector2], crossings: Array[Vector2], item_positions: Array[Vector2])

const WALL_TERRAIN = 0
const ROAD_TERRAIN = 1
const TOWN_TERRAIN = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	var starting_point: Vector2i = generate_maze()
	var town_cells = build_town(starting_point)
	build_pathfinding(town_cells)
	var dead_ends = find_dead_ends()
	var crossings = find_crossings(starting_point)
	var item_positions = get_item_positions(
		road_cells,
		dead_ends.map(maze_position_to_tilemap_position),
		crossings.map(maze_position_to_tilemap_position))
	maze_built.emit(map_to_local(maze_position_to_tilemap_position(starting_point)),
		dead_ends.map(maze_position_to_tilemap_position).map(map_to_local),
		crossings.map(maze_position_to_tilemap_position).map(map_to_local),
		item_positions.map(map_to_local))

func get_point_path(from: Vector2, to: Vector2):
	var from_point: Vector2i = local_to_map(to_local(from))
	var to_point: Vector2i = local_to_map(to_local(to))
	return astar_node.get_point_path(from_point, to_point)

func build_pathfinding(town_cells: Array):
	PathfinderManager.astar_node = astar_node
	astar_node.region = Rect2i(Vector2i.ZERO, Vector2i((MAZE_WIDTH+1)*2+1, (MAZE_HEIGHT+1)*2+1))
	astar_node.cell_size = tile_set.tile_size
	astar_node.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_node.update()
	
	astar_node.fill_solid_region(astar_node.region, true)
	for road_cell in road_cells:
		if not town_cells.has(road_cell):
			astar_node.set_point_solid(road_cell, false)


func generate_maze() -> Vector2i:
	road_cells = []
	generate_initial_walls()
	var path : Array[Vector2i] = []
	
	#var starting_point: Vector2i = choose_border_starting_point()
	var starting_point: Vector2i = Vector2i(randi_range(0, MAZE_WIDTH), randi_range(0, MAZE_HEIGHT))
	
	clear_wall_position(starting_point)
	var current = starting_point
	while true:
		clear_wall_position(current)
		var move = next_move(current)
		if move == Vector2i.ZERO:
			if path.size() > 0:
				current = path.pop_back() #backtracking
				continue
			else:
				break
		clear_wall_position(current)
		clear_wall_between(current, current + move)
		path.append(current)
		current = current + move
		#await get_tree().create_timer(0.25).timeout
	apply_autotile()
	return starting_point

func choose_border_starting_point()-> Vector2i:
	match (randi_range(0, 3)):
		0:
			return Vector2i(0, randi_range(0, MAZE_HEIGHT))
		1:
			return Vector2i(randi_range(0, MAZE_WIDTH), 0)
		2:
			return Vector2i(MAZE_WIDTH, randi_range(0, MAZE_HEIGHT))
		3:
			return Vector2i(randi_range(0, MAZE_WIDTH), MAZE_HEIGHT)
		_:
			return Vector2i(0, 0)

func next_move(previous_position: Vector2i)->Vector2i:
	var movements : Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
	var legal_movements : Array[Vector2i] = []
	for movement in movements:
		if is_legal_position(previous_position + movement) and has_wall(previous_position + movement):
			legal_movements.append(movement)
	
	if legal_movements.size() < 1:
		return Vector2i.ZERO
	return legal_movements.pick_random()

func is_legal_position(testing_position: Vector2i) -> bool:
	return testing_position.x >= 0 and testing_position.x <= MAZE_WIDTH and \
	testing_position.y >= 0 and testing_position.y <= MAZE_HEIGHT

func has_wall(maze_position: Vector2i) -> bool:
	return not road_cells.has(maze_position_to_tilemap_position(maze_position))

func maze_position_to_tilemap_position(maze_position: Vector2i) -> Vector2i:
	return maze_position * 2 + Vector2i.ONE

func clear_wall_position(wall_position: Vector2i) -> void:
	#set_cell(0, maze_position_to_tilemap_position(wall_position), 0, Vector2i(1, 0))
	road_cells.append(maze_position_to_tilemap_position(wall_position))

func clear_wall_between(first_position: Vector2i, second_position: Vector2i) -> void:
	var movement = second_position - first_position
	#set_cell(0, maze_position_to_tilemap_position(first_position) + movement, 0, Vector2i(1, 0))
	road_cells.append(maze_position_to_tilemap_position(first_position) + movement)

func find_crossings(starting_point: Vector2i) -> Array[Vector2i]:
	var crossings: Array[Vector2i] = []
	for j in MAZE_HEIGHT+1:
		for i in MAZE_WIDTH+1:
			if Vector2i(i,j) != starting_point and is_crossing(Vector2i(i,j)):
				crossings.append(Vector2i(i,j))
	return crossings

func find_dead_ends() -> Array[Vector2i]:
	var dead_ends: Array[Vector2i] = []
	for j in MAZE_HEIGHT+1:
		for i in MAZE_WIDTH+1:
			if is_dead_end(Vector2i(i,j)):
					dead_ends.append(Vector2i(i,j))
	return dead_ends

func is_crossing(maze_position: Vector2i) -> bool:
	if not is_legal_position(maze_position):
		return false
	
	var tilemap_position: Vector2i = maze_position_to_tilemap_position(maze_position)
	
	var movements : Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
	return movements.filter(func (movement): return road_cells.has(tilemap_position + movement)).size() > 2

func is_dead_end(maze_position: Vector2i) -> bool:
	if not is_legal_position(maze_position):
		return false
	
	var tilemap_position: Vector2i = maze_position_to_tilemap_position(maze_position)
	
	var movements : Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
	return movements.filter(func (movement): return road_cells.has(tilemap_position + movement)).size() == 1

func build_town(town_maze_position: Vector2i) -> Array:
	var tilemap_position: Vector2i = maze_position_to_tilemap_position(town_maze_position)
	var movements : Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
	movements =  movements.filter(func (movement): return road_cells.has(tilemap_position + movement))
	var town_cells: Array = movements.map(func (movement): return tilemap_position + movement)
	town_cells.append(tilemap_position)
	
	set_cells_terrain_connect(0, town_cells, 0, TOWN_TERRAIN)
	return town_cells

func generate_initial_walls() -> void:
	var cells: Array[Vector2i] = []
	for j in range(-1, (MAZE_HEIGHT+1)*2+2):
		for i in range(-1, (MAZE_WIDTH+1)*2+2):
			cells.append(Vector2i(i, j))
			#set_cell(0, Vector2i(i, j), 0, Vector2i(0, 0))
	set_cells_terrain_connect(0, cells, 0, WALL_TERRAIN, false)

func apply_autotile() -> void:
	set_cells_terrain_connect(0, road_cells, 0, ROAD_TERRAIN)

func get_item_positions(cells: Array, dead_ends: Array, crossings: Array) -> Array:
	var valid_cells: Array = []
	dead_ends = dead_ends.slice(2)
	for cell in cells:
		if not cell in dead_ends and not cell in crossings:
			valid_cells.append(cell)
	return valid_cells
