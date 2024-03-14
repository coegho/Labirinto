extends CharacterBody2D

class_name Player

@export var player_number = 1
@export var max_speed_blocks_per_second = 5
@export var flying_speed_blocks_per_second = 2.5
@export var seconds_until_full_speed: float = 0.25
@export var seconds_until_fully_stopped = 0.15
@export var push_impact = 240

signal player_catched(player: Player)

var max_speed: float:
	get:
		return max_speed_blocks_per_second*32
var acceleration: float:
	get:
		return max_speed/seconds_until_full_speed
var deceleration: float:
	get:
		return max_speed/seconds_until_fully_stopped
var flying_speed: float:
	get:
		return flying_speed_blocks_per_second*32

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var stun_timer = $StunTimer
@onready var item_pick_sound = $ItemPickSound
@onready var catched_sound = $CatchedSound
@onready var item_used_sound = $ItemUsedSound

var orientation : Vector2 = Vector2.RIGHT

var town
var grabbed_object: Item = null
var _salted = false
var _protected = false
var state: PlayerState = PlayerState.NORMAL
var flying_target_position: Vector2

var left_action
var right_action
var up_action
var down_action
var use_action
var drop_action

signal flash_screen()

func _ready():
	assign_input_keys()
	sprite.texture.region.position.y = (player_number-1)*8

func _process(_delta):
	if grabbed_object != null and grabbed_object.has_method("carry"):
		grabbed_object.carry(position + Vector2.UP * 8)

func assign_input_keys():
	match player_number:
		1:
			left_action = "player1_left"
			right_action = "player1_right"
			up_action = "player1_up"
			down_action = "player1_down"
			use_action = "player1_use"
			drop_action = "player1_drop"
		2:
			left_action = "player2_left"
			right_action = "player2_right"
			up_action = "player2_up"
			down_action = "player2_down"
			use_action = "player2_use"
			drop_action = "player2_drop"

func _physics_process(delta):
	if state == PlayerState.STUNNED:
		stunned_process(delta)
	elif state == PlayerState.FLYING:
		flying_process(delta)
	elif state == PlayerState.NORMAL:
		normal_process(delta)

func normal_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal_direction = Input.get_axis(left_action, right_action)
	var vertical_direction = Input.get_axis(up_action, down_action)
	var pressing_use = Input.is_action_just_pressed(use_action)
	var pressing_drop = Input.is_action_just_pressed(drop_action)
	var direction: Vector2 = Vector2(horizontal_direction, vertical_direction)
	if !direction.is_zero_approx():
		direction = direction.normalized()
	
	if grabbed_object != null and pressing_use and grabbed_object.usable:
		item_used_sound.play()
		grabbed_object.use(self)
	elif grabbed_object != null and pressing_drop:
		grabbed_object.drop()
		grabbed_object = null
	
	if direction:
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
		orientation = direction.normalized()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	play_animation(direction)
	if move_and_slide():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.has_method("being_pushed"):
				#outro xogador
				collider.being_pushed(-collision.get_normal().normalized())
				being_pushed(collision.get_normal().normalized())

func stunned_process(_delta):
	animation_player.play("stunned")

func flying_process(delta):
	if orientation.x < 0:
		animation_player.play("fly_left")
	else:
		animation_player.play("fly_right")
	if (global_position - flying_target_position).is_zero_approx():
		state = PlayerState.NORMAL
	else:
		global_position = global_position.move_toward(flying_target_position, flying_speed * delta)

func play_animation(direction):
	var is_grabbing = grabbed_object != null
	if direction:
		if orientation.x < 0:
			if is_grabbing:
				animation_player.play("carry_left")
			else:
				animation_player.play("walk_left")
		else:
			if is_grabbing:
				animation_player.play("carry_right")
			else:
				animation_player.play("walk_right")
	else:
		if orientation.x < 0:
			if is_grabbing:
				animation_player.play("idle_carry_left")
			else:
				animation_player.play("idle_left")
		else:
			if is_grabbing:
				animation_player.play("idle_carry_right")
			else:
				animation_player.play("idle_right")

func being_catched():
	if grabbed_object != null:
		grabbed_object.drop(state == PlayerState.FLYING)
		grabbed_object = null
	scare()
	position = town.position
	player_catched.emit(self)

func grab(object):
	if grabbed_object != null:
		grabbed_object.drop()
	grabbed_object = object
	item_pick_sound.play()

func enter_town():
	if grabbed_object != null and grabbed_object.collectable:
		grabbed_object.collect(self)

func set_salted(salted: bool):
	_salted = salted

func is_salted() -> bool:
	return _salted

func set_protected(protected: bool):
	_protected = protected
	
func is_protected() -> bool:
	return _protected

func scare():
	flash_screen.emit()
	if state == PlayerState.FLYING:
		global_position = flying_target_position
	state = PlayerState.STUNNED
	stun_timer.start()
	catched_sound.play()

func fly_to(target_position: Vector2):
	state = PlayerState.FLYING
	flying_target_position = target_position

func being_pushed(other_velocity: Vector2):
	velocity = other_velocity * push_impact

func _on_stun_timer_timeout():
	state = PlayerState.NORMAL

enum PlayerState {
	NORMAL, STUNNED, FLYING
}
