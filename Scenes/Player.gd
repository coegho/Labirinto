extends CharacterBody2D

class_name Player

@export var max_speed_blocks_per_second = 5
@export var flying_speed_blocks_per_second = 2.5
@export var seconds_until_full_speed: float = 0.25
@export var seconds_until_fully_stopped = 0.15
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
		
@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var stun_timer = $StunTimer

var orientation : Vector2 = Vector2.RIGHT

var town
var grabbed_object: Item = null
var _salted = false
var _protected = false
var state: PlayerState = PlayerState.NORMAL
var flying_target_position: Vector2

signal flash_screen()

func _process(_delta):
	if grabbed_object != null and grabbed_object.has_method("carry"):
		grabbed_object.carry(position + Vector2.UP * 8)

func _physics_process(delta):
	if state == PlayerState.STUNNED:
		return
	if state == PlayerState.FLYING:
		if orientation.x < 0:
			animation_player.play("fly_left")
		else:
			animation_player.play("fly_right")
		var move = (flying_target_position - global_position)
		if (global_position - flying_target_position).is_zero_approx():
			state = PlayerState.NORMAL
		else:
			global_position = global_position.move_toward(flying_target_position, flying_speed * delta)
		return
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal_direction = Input.get_axis("ui_left", "ui_right")
	var vertical_direction = Input.get_axis("ui_up", "ui_down")
	var use_action = Input.is_physical_key_pressed(KEY_Q)
	var direction: Vector2 = Vector2(horizontal_direction, vertical_direction)
	if !direction.is_zero_approx():
		direction = direction.normalized()
	
	if grabbed_object != null and use_action and grabbed_object.usable:
		grabbed_object.use(self)
	
	if direction:
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
		orientation = direction.normalized()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	play_animation(direction)
	move_and_slide()

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
		grabbed_object.drop(null)
		grabbed_object = null
	scare()
	position = town.position

func grab(object):
	if grabbed_object != null:
		grabbed_object.drop(object)
	grabbed_object = object
	pass

func enter_town():
	if grabbed_object != null and grabbed_object.has_method("entering_town"):
		grabbed_object.entering_town()

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

func fly_to(target_position: Vector2):
	state = PlayerState.FLYING
	flying_target_position = target_position

func _on_stun_timer_timeout():
	state = PlayerState.NORMAL

enum PlayerState {
	NORMAL, STUNNED, FLYING
}
