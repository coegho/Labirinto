extends SubViewport

@export var original_viewport: SubViewport

func _ready():
	if original_viewport != null:
		world_2d = original_viewport.world_2d
