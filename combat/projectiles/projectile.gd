class_name Projectile
extends Area2D

@export var shard_tscn: PackedScene

@onready var sprite = $AnimatedSprite2D

# Core properties
var speed: float
var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0
var element: Enums.Elements = Enums.Elements.NONE
var _shard_element: Enums.Elements = Enums.Elements.NONE
var max_distance: float

# State
var distance_traveled: float = 0.0
var has_hit: bool = false
var can_spawn_shard: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	sprite.modulate = ElementalManager.get_element_color(element)
	sprite.play("default")
	
func setup(
	fire_direction: Vector2,
	proj_speed: float,
	proj_damage: float,
	proj_element: Enums.Elements,
	shard_element: Enums.Elements,
	max_range: float = 250.0
	):
	direction = fire_direction.normalized()
	speed = proj_speed
	damage = proj_damage
	element = proj_element
	_shard_element = shard_element
	max_distance = max_range
	rotation = direction.angle()
	
func _physics_process(delta: float) -> void:
	if has_hit:
		return
		
	var movement = speed * direction * delta
	distance_traveled += movement.length()
	position += movement
	
	if distance_traveled >= max_distance:
		queue_free()
		

func _on_area_entered(_area: Area2D) -> void:
	# Hurtbox owner determined by collision mask
	_on_impact()

func _on_body_entered(_body: Node2D) -> void:
	# Handle hitting walls, buildings, etc
	_on_impact()

func _on_impact() -> void:
	if has_hit:
		return
	has_hit = true
	
	if can_spawn_shard:
		spawn_shard_at_position(global_position, _shard_element)
	
	queue_free()
	
func spawn_shard_at_position(shard_position: Vector2, shard_element: Enums.Elements) -> void:
	if not shard_tscn:
		push_warning("shard scene not assigned")
		return
		
	var shard = shard_tscn.instantiate() as ElementalShard
	shard.setup(shard_position, shard_element)
	get_tree().current_scene.add_child(shard)
	

func _exit_tree() -> void:
	# Disconnect signals during queue_free to prevent same frame emissions
	if area_entered.is_connected(_on_area_entered):
		area_entered.disconnect(_on_area_entered)
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
