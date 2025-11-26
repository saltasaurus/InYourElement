class_name ElementalShard
extends Area2D

signal collected(element: Enums.Elements)

@onready var lifetime_timer = $LifeTimer
@onready var sprite = $Sprite2D

var element: Enums.Elements

func _ready() -> void:
	_set_elemental_modulation()
	lifetime_timer.timeout.connect(_on_timeout)
	lifetime_timer.start()
	
func setup(pos: Vector2, shard_element: Enums.Elements) -> void:
	global_position = pos
	element = shard_element
	
		
func _set_elemental_modulation() -> void:
	match element:
		Enums.Elements.FIRE:
			sprite.modulate = Color.RED
		Enums.Elements.WATER:
			sprite.modulate = Color.BLUE
		Enums.Elements.EARTH:
			sprite.modulate = Color.BROWN
		Enums.Elements.AIR:
			sprite.modulate = Color.LIGHT_GRAY 

func _on_timeout() -> void:
	queue_free()
	
func collect() -> void:
	print("Collected ", Enums.Elements.keys()[element], " shard!")
	collected.emit(element)
	queue_free()
