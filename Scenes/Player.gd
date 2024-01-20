extends CharacterBody2D


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
		if last_side == Vector2i.LEFT:
			animation_player.play("walk_left")
		else:
			animation_player.play("walk_right")
	else:
		if last_side == Vector2i.LEFT:
			animation_player.play("idle_left")
		else:
			animation_player.play("idle_right")
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()
