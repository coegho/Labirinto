extends Node

var score: Array[int] = [0,0]


func _on_level_player_catched(player_number):
	score[player_number-1] = score[player_number-1] - 1
	print(score[player_number-1])


func _on_level_herb_collected(player_number):
	score[player_number-1] = score[player_number-1] + 1
	print(score[player_number-1])
