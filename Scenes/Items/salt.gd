extends Node2D

class_name Salt

signal salt_used(position : Vector2)

func use(player):
	salt_used.emit(player.global_position)
	queue_free()
