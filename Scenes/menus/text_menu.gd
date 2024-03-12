extends CanvasLayer

signal return_to_menu_pressed

func _on_button_pressed():
	return_to_menu_pressed.emit()
