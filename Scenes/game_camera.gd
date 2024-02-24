extends Camera2D

@export var follow: Node2D

@onready var flash_effect = %FlashEffect

# Called every frame. 'delta' is the elapsed time since"Level/CanvasLayer/HBoxContainer/SubViewportContainer1/Viewport1/World" the previous frame.
func _process(_delta):
	if follow != null:
		position = follow.position
	else:
		var horizontal_direction = Input.get_axis("ui_left", "ui_right")
		var vertical_direction = Input.get_axis("ui_up", "ui_down")
		var direction: Vector2 = Vector2(horizontal_direction, vertical_direction)
		global_position = global_position + direction * 20 * _delta
		print(global_position)


func _on_player_flash_screen():
	flash_effect.flash()
