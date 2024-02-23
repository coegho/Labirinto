extends Node2D

class_name Salt

signal salt_used(position : Vector2)

func use(position_used : Vector2):
	salt_used.emit(position_used)
	queue_free()
