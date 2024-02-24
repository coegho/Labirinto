extends Node2D

class_name Herb

@onready var sprite = $Sprite2D
@onready var item: Item = %Item

signal saved_herb(herb: Herb, player: Player)

#func _ready():
	#sprite.frame = randi_range(0,6)



func _on_item_object_collected(player: Player):
	item.drop(null)
	saved_herb.emit(self, player)
	queue_free()
