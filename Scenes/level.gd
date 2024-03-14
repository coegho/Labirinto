extends Node

@onready var ui: UI = %UI
@onready var world: World = $CanvasLayer/HBoxContainer/SubViewportContainer1/Viewport1/World

var number_of_players: int

signal player_catched(player_number: int)
signal herb_collected(player_number: int)
signal all_herbs_collected()

func _ready():
	world.number_of_players = number_of_players

func add_herb(herb: Herb, player: Player):
	herb_collected.emit(player.player_number)
	if ui.add_herb_score(herb):
		all_herbs_collected.emit()

func _on_player_catched(player: Player):
	player_catched.emit(player.player_number)


func _on_world_created_herbs(herbs: Array):
	for herb in herbs:
		herb.saved_herb.connect(add_herb)
	ui.set_herb_score(0, herbs.size())
