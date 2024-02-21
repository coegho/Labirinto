extends Node2D


func _on_area_2d_body_entered(body):
	if body.has_method("set_salted"):
		body.set_salted(true)


func _on_area_2d_body_exited(body):
	if body.has_method("set_salted"):
		body.set_salted(false)
