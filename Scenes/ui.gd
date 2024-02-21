extends CanvasLayer

class_name UI

@onready var label = %Label

signal all_herbs_collected()

var _current_score = 0
var _max_score = 0

func set_herb_score(current_score, max_score):
	_current_score = current_score
	_max_score = max_score
	label.text = str(_current_score, "/", _max_score)

func add_herb_score(score):
	_current_score = _current_score + score
	label.text = str(_current_score, "/", _max_score)
	if _current_score == _max_score:
		all_herbs_collected.emit()
