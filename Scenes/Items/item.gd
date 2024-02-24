extends Node2D

class_name Item

@export var usable = false
@export var collectable = false

var original_position: Vector2
var grabbed_by: Player = null

signal using_object()
signal object_collected(player: Player)
signal grabbing_object(player)
signal dropping_object(player)

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = get_parent().position

func _on_area_2d_body_entered(player):
	if grabbed_by == null and player.has_method("grab"):
		grabbed_by = player
		player.grab(self)
		grabbing_object.emit(player)

func drop(back_to_original_position = false):
	if grabbed_by != null:
		if back_to_original_position:
			get_parent().position = original_position
		else:
			get_parent().position = grabbed_by.global_position
		dropping_object.emit(grabbed_by)
		grabbed_by = null


func use(player: Player):
	if get_parent().has_method("use"):
		get_parent().use(player)
		using_object.emit()

func carry(new_position: Vector2):
	get_parent().position = new_position

func collect(player: Player):
	object_collected.emit(player)
