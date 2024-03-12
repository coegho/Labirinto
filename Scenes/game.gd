extends Node

class_name Game

var score: Array[PlayerScore] = []

@onready var score_display = $ScoreDisplay
var level

var number_of_players: int

@export var level_scene: PackedScene

@onready var grid_container: GridContainer = $ScoreDisplay/MarginContainer/GridContainer
@onready var lbl_player: Array[Label] = [
	$ScoreDisplay/MarginContainer/GridContainer/lblPlayer1,
	$ScoreDisplay/MarginContainer/GridContainer/lblPlayer2
]
@onready var lbl_catched: Array[Label] = [
	$ScoreDisplay/MarginContainer/GridContainer/lblCatched1,
	$ScoreDisplay/MarginContainer/GridContainer/lblCatched2
]
@onready var lbl_herbs_collected: Array[Label] = [
	$ScoreDisplay/MarginContainer/GridContainer/lblHerbsCollected1,
	$ScoreDisplay/MarginContainer/GridContainer/lblHerbsCollected2
]
@onready var lbl_total_score: Array[Label] = [
	$ScoreDisplay/MarginContainer/GridContainer/lblTotalScore1,
	$ScoreDisplay/MarginContainer/GridContainer/lblTotalScore2
]

signal go_to_menu_pressed

func _ready():
	new_game()

func new_game():
	score = [
		PlayerScore.new(),
		PlayerScore.new()
	]
	score_display.visible = false
	
	if level != null:
		level.queue_free()
	level = level_scene.instantiate()
	level.number_of_players = number_of_players
	add_child(level)
	move_child(level, 0)
	level.herb_collected.connect(_on_level_herb_collected)
	level.player_catched.connect(_on_level_player_catched)
	level.all_herbs_collected.connect(_on_level_all_herbs_collected)
	get_tree().paused = false

func _on_level_player_catched(player_number):
	score[player_number-1].catched_points = score[player_number-1].catched_points - 1


func _on_level_herb_collected(player_number):
	score[player_number-1].herb_points = score[player_number-1].herb_points + 1


func _on_level_all_herbs_collected():
	for player in [0,1]:
		grid_container.columns = number_of_players + 1
		var visible_data = number_of_players > player
		lbl_player[player].visible = visible_data
		lbl_catched[player].visible = visible_data
		lbl_herbs_collected[player].visible = visible_data
		lbl_total_score[player].visible = visible_data
		
		lbl_catched[player].text = str(score[player].catched_points)
		lbl_herbs_collected[player].text = str(score[player].herb_points)
		lbl_total_score[player].text = str(score[player].herb_points + score[player].catched_points)	
	score_display.visible = true

class PlayerScore:
	var herb_points: int = 0
	var catched_points: int = 0


func _on_btn_new_game_pressed():
	new_game()


func _on_btn_exit_pressed():
	get_tree().paused = false
	go_to_menu_pressed.emit()
