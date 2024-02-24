extends CanvasLayer

class_name UI

var herb_textures: Array

var _current_score = 0
var _max_score = 0

func _ready():
	herb_textures = [
		%Herb1,
		%Herb2,
		%Herb3,
		%Herb4,
		%Herb5,
		%Herb6,
		%Herb7
		]

func set_herb_score(current_score, max_score):
	_current_score = current_score
	_max_score = max_score
	for tex in herb_textures:
		tex.modulate = Color(0,0,0,1)
	for i in range(max_score, 7, 1):
		herb_textures[i].visible = false

func add_herb_score(herb: Herb) -> bool:
	_current_score = _current_score + 1
	herb_textures[herb.sprite.frame].modulate = Color(1,1,1,1)
	return _current_score == _max_score
