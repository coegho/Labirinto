extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_grabbing_object(player):
	if player.has_method("set_protected"):
		player.set_protected(true)


func _on_item_dropping_object(player):
	if player.has_method("set_protected"):
		player.set_protected(false)
