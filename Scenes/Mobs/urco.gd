extends AnimatableBody2D

class_name Urco

@export var speed: float = 75
@export var attack_speed: float = 150

@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var sight = $Sight
@onready var timer = $RecoverTimer
@onready var growl_sound = $GrowlSound

var pending_path: Array = []

var crossings: Array = []

var current_state : urco_states = urco_states.WALK
var last_direction = Vector2i.RIGHT
var target : Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):	
	if current_state == urco_states.ATTACK:
		attack_mode(delta)
	elif current_state == urco_states.WALK:
		walk_mode(delta)
	else:
		animation_player.play("idle")

func attack_mode(delta):
	var move = target - global_position
	if move.is_zero_approx():
		current_state = urco_states.WAIT
		growl_sound.stop()
		pending_path = []
		timer.start()
	if move.x > 0:
		last_direction = Vector2i.RIGHT
	elif move.x < 0:
		last_direction = Vector2i.LEFT
	if last_direction == Vector2i.RIGHT:
		animation_player.play("run_right")
	else:
		animation_player.play("run_left")
	#position = position.move_toward(target, attack_speed * delta)
	if speed * delta < move.length():
		move = move.normalized() * speed * delta
	var collision = move_and_collide(move)
	if collision != null:
		current_state = urco_states.WAIT
		growl_sound.stop()
		pending_path = []
		timer.start()
	

func walk_mode(delta):
	var visible_players : Array = sight.get_players_on_sight()
	visible_players = visible_players.filter(func (player):
		return player.has_method("is_protected") and !player.is_protected())
	if !visible_players.is_empty():
		current_state = urco_states.ATTACK
		growl_sound.play()
		target = visible_players[0].global_position
		return
	
	if pending_path.size() > 0:
		var next: Vector2 = pending_path[0]
		var move = next - position
		if move.is_zero_approx():
			pending_path.pop_front()
		else:
			if move.x > 0:
				last_direction = Vector2i.RIGHT
			elif move.x < 0:
				last_direction = Vector2i.LEFT
			if last_direction == Vector2i.RIGHT:
				animation_player.play("walk_right")
			else:
				animation_player.play("walk_left")
			#position = position.move_toward(next, speed * delta)
			if speed * delta < move.length():
				move = move.normalized() * speed * delta
			move_and_collide(move)
	else:
		pending_path = PathfinderManager.get_point_path_global(position, crossings.pick_random())

func _on_hitbox_body_entered(body):
	if body.has_method("being_catched") and !body.is_protected():
		body.being_catched()


enum urco_states {
	WALK, ATTACK, WAIT
}

func _on_recover_timer_timeout():
	current_state = urco_states.WALK
	growl_sound.stop()
