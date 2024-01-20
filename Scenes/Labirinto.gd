extends TileMap

class_name Labirinto

const MAZE_WIDTH: int = 8
const MAZE_HEIGHT: int = 8

@export var wall_coords : Vector2i = Vector2i(0, 0)
@export var road_coords : Vector2i = Vector2i(1, 0)

@onready var astar_node: AStarGrid2D = AStarGrid2D.new()

var dead_ends : Array[Vector2i] = []

signal maze_built(starting_point: Vector2, dead_ends: Array[Vector2])

# Called when the node enters the scene tree for the first time.
func _ready():
	var starting_point: Vector2i = generate_maze()
	build_pathfinding()
	maze_built.emit(map_to_local(maze_position_to_tilemap_position(starting_point)),
		dead_ends.map(maze_position_to_tilemap_position).map(map_to_local))

func get_point_path(from: Vector2, to: Vector2):
	var from_point: Vector2i = local_to_map(to_local(from))
	var to_point: Vector2i = local_to_map(to_local(to))
	return astar_node.get_point_path(from_point, to_point)

func build_pathfinding():
	PathfinderManager.astar_node = astar_node
	astar_node.region = Rect2i(Vector2i.ZERO, Vector2i((MAZE_WIDTH+1)*2+1, (MAZE_HEIGHT+1)*2+1))
	astar_node.cell_size = tile_set.tile_size
	astar_node.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_node.update()
	
	var obstacles = get_used_cells_by_id(0, -1, wall_coords)
	for obstacle in obstacles:
		astar_node.set_point_solid(obstacle)


func generate_maze() -> Vector2i:
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
				dead_ends.append(current)
				current = path.pop_back() #backtracking
				continue
			else:
				break
		
		clear_wall_position(current)
		clear_wall_between(current, current + move)
		path.append(current)
		current = current + move
		#await get_tree().create_timer(0.25).timeout
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

func has_wall(testing_position: Vector2i) -> bool:
	return get_cell_atlas_coords(0, maze_position_to_tilemap_position(testing_position)) == wall_coords

func maze_position_to_tilemap_position(maze_position: Vector2i) -> Vector2i:
	return maze_position * 2 + Vector2i.ONE

func clear_wall_position(wall_position: Vector2i) -> void:
	set_cell(0, maze_position_to_tilemap_position(wall_position), 0, Vector2i(1, 0))

func clear_wall_between(first_position: Vector2i, second_position: Vector2i) -> void:
	var movement = second_position - first_position
	set_cell(0, maze_position_to_tilemap_position(first_position) + movement, 0, Vector2i(1, 0))

func generate_initial_walls() -> void:
	for j in (MAZE_HEIGHT+1)*2+1:
		for i in (MAZE_WIDTH+1)*2+1:
			set_cell(0, Vector2i(i, j), 0, Vector2i(0, 0))

func generate_external_borders():
	for i in MAZE_HEIGHT*2:
		set_cell(0, Vector2i(0, i), 0, Vector2i(0, 0))
		set_cell(0, Vector2i(MAZE_WIDTH*2-1, i), 0, Vector2i(0, 0))
	for i in MAZE_WIDTH*2:
		set_cell(0, Vector2i(i, 0), 0, Vector2i(0, 0))
		set_cell(0, Vector2i(i, MAZE_HEIGHT*2-1), 0, Vector2i(0, 0))
