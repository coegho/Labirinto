extends CharacterBody2D

class_name Player

@export var speed_blocks_per_second = 4
@export var seconds_until_full_speed: float = 0.25
@export var seconds_until_fully_stopped = 0.15
var speed: float:
	get:
		return speed_blocks_per_second*32
var acceleration: float:
	get:
		return speed/seconds_until_full_speed
var deceleration: float:
	get:
		return speed/seconds_until_fully_stopped
@onready var animation_player = $Sprite2D/AnimationPlayer
var last_side = Vector2i.RIGHT

var town
var grabbed_object = null
var _salted = false

func _process(_delta):
	if grabbed_object != null and grabbed_object.has_method("carry"):
		grabbed_object.carry(position + Vector2.UP * 8)

func _physics_process(delta):

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal_direction = Input.get_axis("ui_left", "ui_right")
	var vertical_direction = Input.get_axis("ui_up", "ui_down")
	var direction: Vector2 = Vector2(horizontal_direction, vertical_direction)
	if !direction.is_zero_approx():
		direction = direction.normalized()
	
	if direction:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		if velocity.x < 0:
			last_side = Vector2i.LEFT
		elif velocity.x > 0:
			last_side = Vector2i.RIGHT
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	play_animation(direction)
	move_and_slide()

func play_animation(direction):
	var is_grabbing = grabbed_object != null
	if direction:
		if last_side == Vector2i.LEFT:
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
		if last_side == Vector2i.LEFT:
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

func get_salted() -> bool:
	return _salted
