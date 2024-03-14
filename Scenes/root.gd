extends Node2D

@onready var current_menu = $CurrentMenu
@onready var audio_player = $AudioStreamPlayer

const menus: Dictionary = {
	"main_menu": preload("res://Scenes/Menus/main_menu.tscn"),
	"instructions_menu": preload("res://Scenes/Menus/instructions_menu.tscn"),
	"credits_menu": preload("res://Scenes/Menus/credits_menu.tscn"),
	"controls_menu": preload("res://Scenes/Menus/controls_menu.tscn"),
}

func show_main_menu() -> MainMenu:
	var menu: MainMenu = switch_menu("main_menu")
	menu.new_game_pressed.connect(_on_main_menu_new_game_pressed)
	menu.menu_button_pressed.connect(_on_main_menu_menu_button_pressed)
	if !audio_player.playing:
		audio_player.play()
	return menu

func load_game(number_of_players):
	for children in current_menu.get_children():
		children.queue_free()
	var game = preload("res://Scenes/game.tscn").instantiate()
	game.number_of_players = number_of_players
	game.go_to_menu_pressed.connect(_on_return_to_menu_pressed)
	audio_player.stop()
	return game

func load_menu(menu_name: String):
	if menus.has(menu_name):
		var menu = menus[menu_name].instantiate()
		if menu.has_signal("return_to_menu_pressed"):
			menu.return_to_menu_pressed.connect(_on_return_to_menu_pressed)
		return menu
	else:
		printerr("Cannot find menu %s" % menu_name)
		return null

func switch_menu(menu_name: String):
	for children in current_menu.get_children():
		children.queue_free()
	return load_menu(menu_name)

func _ready():
	SettingsManager.load_settings()
	current_menu.add_child(show_main_menu())

func _on_main_menu_new_game_pressed(number_of_players: int):
	current_menu.add_child(load_game(number_of_players))
	
func _on_return_to_menu_pressed():
	current_menu.add_child(show_main_menu())

func _on_main_menu_menu_button_pressed(menu_name):
	current_menu.add_child(switch_menu(menu_name))
