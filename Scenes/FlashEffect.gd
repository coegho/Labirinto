extends Node2D

@onready var timer : Timer = $Timer
@onready var sprite : Sprite2D = $FlashSprite

@export var speed = 15
var is_flashing : bool = false
var direction : int = 1

func _process(delta):
	if is_flashing:
		sprite.modulate.a = clamp(sprite.modulate.a + speed*direction*delta, 0, 1)
		if sprite.modulate.a >= 1 or sprite.modulate.a <= 0:
			direction = -direction
			

func flash():
	is_flashing = true
	timer.start()


func _on_timer_timeout():
	is_flashing = false
	sprite.modulate.a = 0


func _on_player_1_flash_screen():
	flash()
