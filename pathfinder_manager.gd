extends Node

var astar_node: AStarGrid2D

func cell_to_global(cell: Vector2i) -> Vector2:
	var cell_size = astar_node.cell_size
	var region_position = astar_node.region.position
	var global_point = Vector2(region_position.x + cell.x * cell_size.x + cell_size.x/2,
		region_position.y + cell.y * cell_size.y + cell_size.y/2)
	return global_point

func global_to_cell(point: Vector2) -> Vector2i:
	var cell_size = astar_node.cell_size
	var region_position = astar_node.region.position
	var cell = Vector2i(floor((point.x - region_position.x)/cell_size.x),
		floor((point.y - region_position.y)/cell_size.y))
	return cell

func get_point_path(from: Vector2i, to: Vector2i) -> Array:
	return astar_node.get_id_path(from, to).map(cell_to_global)

func get_point_path_global(from: Vector2, to: Vector2) -> Array:
	return get_point_path(global_to_cell(from), global_to_cell(to))
