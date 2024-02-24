extends Node2D

class_name Vasoira

signal used_broom(player: Player)

func use(player: Player):
	var target_position = player.global_position + player.orientation * 64
	if is_empty(target_position):
		player.fly_to(target_position)
		used_broom.emit(player)

func is_empty(testing_position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsPointQueryParameters2D.new()
	query.position = testing_position
	query.collision_mask = 0b00000000_00000000_00000000_00000010
	var result = space_state.intersect_point(query)
	return result.is_empty()
