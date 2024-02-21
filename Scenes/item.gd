extends Node2D

class_name Item

var original_position: Vector2
var grabbed_by: Player = null

signal _entering_town()

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = get_parent().position

func _on_area_2d_body_entered(player):
	if grabbed_by == null and player.has_method("grab"):
		grabbed_by = player
		player.grab(self)

func drop(switch):
	if grabbed_by != null:
		if switch == null:
			get_parent().position = original_position
		else:
			get_parent().position = switch.get_parent().position
		grabbed_by = null

func carry(new_position: Vector2):
	get_parent().position = new_position

func entering_town():
	_entering_town.emit()
