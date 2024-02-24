extends Node2D

class_name Meiga

@export var speed = 50
@export var descending_speed = 75
var flying_height: float

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var catching_area: Area2D = $CatchingArea

var center_point: Vector2
var rotating_path: Array = []
var current_path_index = 0
var chased_player: Player = null
var state: MeigaState = MeigaState.FLYING

func _ready():
	flying_height = - sprite.position.y
	center_point = global_position
	rotating_path = calculate_circle_path(center_point, 5*32)

func _physics_process(delta):
	if state == MeigaState.FLYING:
		flying_process(delta)
	elif state == MeigaState.CHASING:
		chasing_process(delta)
	elif state == MeigaState.DESCENDING:
		descending_process(delta)

func flying_process(delta):
	sprite.position = sprite.position.move_toward(Vector2(0, -flying_height), speed * delta)
	catching_area.monitoring = false
	
	if current_path_index >= rotating_path.size():
		current_path_index = current_path_index % rotating_path.size()
	
	var next: Vector2 = rotating_path[current_path_index]
	var move = next - position
	if move.is_zero_approx():
		current_path_index = current_path_index + 1
	else:
		if move.x > 0:
			animation_player.play("fly_right")
		elif move.x < 0:
			animation_player.play("fly_left")
		position = position.move_toward(next, speed * delta)

func chasing_process(delta):
	sprite.position = sprite.position.move_toward(Vector2(0, -flying_height), speed * delta)
	catching_area.monitoring = false
	
	if chased_player == null or is_player_in_town(chased_player.global_position):
		chased_player = null
		state = MeigaState.FLYING
		return
	var move = chased_player.global_position - global_position
	if move.x > 0:
		animation_player.play("fly_right")
	elif move.x < 0:
		animation_player.play("fly_left")
	position = position.move_toward(chased_player.global_position, speed * delta)
	if (position - chased_player.global_position).is_zero_approx():
		state = MeigaState.DESCENDING

func descending_process(delta):
	sprite.position = sprite.position.move_toward(Vector2.ZERO, descending_speed * delta)
	if sprite.position.y > -10:
		catching_area.monitoring = true
	if sprite.position.is_zero_approx():
		state = MeigaState.CHASING
		catching_area.monitoring = false

func calculate_circle_path(center: Vector2, radius: float) -> Array:
	var path: Array[Vector2] = []
	for i in range(0, 360, 360.0/16):
		path.append((Vector2.RIGHT * radius).rotated(deg_to_rad(i)) + center)
	return path

func player_used_broom(player: Player):
	if state == MeigaState.FLYING:
		chased_player = player
		state = MeigaState.CHASING

func is_player_in_town(test_position: Vector2):
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsPointQueryParameters2D.new()
	query.position = test_position
	query.collision_mask = 0b00000000_00000000_00000000_00010000
	var result = space_state.intersect_point(query)
	return !result.is_empty()

enum MeigaState {
	FLYING, CHASING, DESCENDING
}


func _on_catching_area_body_entered(body):
	if body.has_method("is_protected") and body.is_protected():
		state = MeigaState.FLYING
	elif body.has_method("being_catched"):
		body.being_catched()
		state = MeigaState.FLYING
