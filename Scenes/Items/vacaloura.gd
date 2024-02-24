extends Node2D


func _on_item_grabbing_object(player):
	if player.has_method("set_protected"):
		player.set_protected(true)


func _on_item_dropping_object(player):
	if player.has_method("set_protected"):
		player.set_protected(false)
