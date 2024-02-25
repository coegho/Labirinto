extends Camera2D

@export var follow: Node2D

@onready var flash_effect = %FlashEffect

# Called every frame. 'delta' is the elapsed time since"Level/CanvasLayer/HBoxContainer/SubViewportContainer1/Viewport1/World" the previous frame.
func _process(_delta):
	if follow != null:
		position = follow.position


func _on_player_flash_screen():
	flash_effect.flash()
