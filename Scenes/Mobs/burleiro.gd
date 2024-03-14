extends Node2D

class_name Burleiro

@onready var herb_sprite : Sprite2D = $HerbSprite
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_player : AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var timer : Timer = $Timer
@onready var failed_scare_sound = $FailedScareSound

@export var speed : float = 150

var hidden_enemy : bool
var dead_ends : Array
var pending_path : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	hidden_enemy = true
	herb_sprite.frame = randi_range(0, 6)

func _physics_process(delta):
	if !hidden_enemy:
		if pending_path.size() > 0:
			var next: Vector2 = pending_path[0]
			var move = next - position
			if move.is_zero_approx():
				pending_path.pop_front()
			else:
				if move.x > 0:
					animation_player.play("run_right")
				elif move.x < 0:
					animation_player.play("run_left")
				position = position.move_toward(next, speed * delta)
		else:
			hidden_enemy = true
			herb_sprite.visible = true
			sprite.visible = false

func _on_area_2d_body_entered(body):
	if hidden_enemy:
		herb_sprite.visible = false
		sprite.visible = true
		animation_player.play("scare")
		if body.has_method("scare") and !body.is_protected():
			body.scare()
		else:
			failed_scare_sound.play()
		timer.start()


func _on_timer_timeout():
	hidden_enemy = false
	var next_position = position
	while next_position == position:
		next_position = dead_ends.pick_random()
	pending_path = PathfinderManager.get_point_path_global(position, next_position)
	animation_player.play("run_right")
