extends Node2D

class_name Urco

@export var speed: float = 75

@onready var animation_player = $Sprite2D/AnimationPlayer

var pending_path: Array = []

var crossings: Array = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pending_path.size() > 0:
		var next: Vector2 = pending_path[0]
		var move = next - position
		if move.is_zero_approx():
			pending_path.pop_front()
		else:
			if move.x > 0:
				animation_player.play("walk_right")
			elif move.x < 0:
				animation_player.play("walk_left")
			position = position.move_toward(next, speed * delta)
	else:
		pending_path = PathfinderManager.get_point_path_global(position, crossings.pick_random())
