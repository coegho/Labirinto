extends CanvasLayer

class_name MainMenu

signal new_game_pressed(number_of_players: int)
signal menu_button_pressed(menu_name: String)


func _on_btn_new_game_1_pressed():
	new_game_pressed.emit(1)

func _on_btn_new_game_2_pressed():
	new_game_pressed.emit(2)

func _on_btn_instructions_pressed():
	menu_button_pressed.emit("instructions_menu")


func _on_btn_controls_pressed():
	menu_button_pressed.emit("controls_menu")


func _on_btn_credits_pressed():
	menu_button_pressed.emit("credits_menu")
