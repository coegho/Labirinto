extends Area2D

var players_in_sight_area : Array = []

func get_players_on_sight() -> Array:
	var players : Array = players_in_sight_area.filter(is_player_on_sight)
	players.sort_custom(func (p1, p2):
		return (p2.global_position - global_position).length() > (p1.global_position - global_position).length())
	return players

func is_player_on_sight(player) -> bool:
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(
		global_position, player.global_position, 0b00000000_00000000_00000000_00010010, [self,player])
	var result = space_state.intersect_ray(query)
	return result.is_empty()

func _on_body_entered(body):
	players_in_sight_area.append(body)


func _on_body_exited(body):
	players_in_sight_area.erase(body)
