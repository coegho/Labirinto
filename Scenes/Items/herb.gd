extends Node2D

class_name Herb

@onready var sprite = $Sprite2D
@onready var item: Item = %Item

signal saved_herb()

func _ready():
	sprite.frame = randi_range(0,6)


func _on_item__entering_town():
	item.drop(null)
	saved_herb.emit()
	queue_free()
