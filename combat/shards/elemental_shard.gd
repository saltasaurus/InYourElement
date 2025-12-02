class_name ElementalShard
extends Area2D

signal collected(element: Enums.Elements)

@onready var spawn_timer = $SpawnTimer
@onready var lifetime_timer = $LifeTimer
@onready var sprite = $ColorRect
@onready var collection_radius := $CollectionRadius


var element: Enums.Elements
var is_collectable = false # Can't collect immediately
var _target_pos: Vector2 = position

func _ready() -> void:
	_set_elemental_modulation()
	spawn_timer.timeout.connect(_on_spawn_timeout)
	lifetime_timer.timeout.connect(_on_timeout)
	spawn_timer.start()
	lifetime_timer.start()
	
func _set_elemental_modulation() -> void:
	sprite.modulate = ElementalManager.get_element_color(element)
			
	print("Color: ", sprite.color)
	
func setup(pos: Vector2, shard_element: Enums.Elements) -> void:
	global_position = pos
	element = shard_element
	
		
func _process(delta: float) -> void:
	if not is_collectable:
		return
		
	var direction = (_target_pos - position).normalized()
	position += direction * delta
		

func _on_spawn_timeout() -> void:
	is_collectable = true
	print("Can collect")
	
func _on_timeout() -> void:
	queue_free()
	
func collect() -> void:
	print("Collecting ", Enums.Elements.keys()[element], " shard!")
	collected.emit(element)
	queue_free()
