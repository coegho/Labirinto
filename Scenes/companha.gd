extends Node2D

class_name Companha

@export var speed: float = 50

@onready var animation_player = $Sprite2D/AnimationPlayer

var pending_path: Array = []

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if pending_path.size() > 0:
		var next: Vector2 = pending_path[0]
		var move = next - position
		if move.is_zero_approx():
			pending_path.pop_front()
		else:
			if move.x > 0:
				animation_player.play("walking_right")
			elif move.x < 0:
				animation_player.play("walking_left")
			position = position.move_toward(next, speed * delta)
	else:
		pending_path = PathfinderManager.get_point_path_global(position, player.position)
