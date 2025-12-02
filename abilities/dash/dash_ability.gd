class_name DashAbility
extends Ability

@export var shard_tscn: PackedScene
@export var dash_speed: float = 500.0
@export var dash_distance: float = 50.0
@export var base_element: Enums.Elements

var owner_entity: CharacterBody2D
var dash_direction: Vector2

func _ready() -> void:
	owner_entity = owner as CharacterBody2D
	ability_duration = dash_distance / dash_speed

func _process(delta: float) -> void:
	super._process(delta)
	
	if is_active:
		owner_entity.velocity = dash_direction * dash_speed

func _on_execute() -> void:
	dash_direction = _get_dash_direction()
	print("Started dashing!")
	
func _get_dash_direction() -> Vector2:
	if owner_entity.has_method("get_movement_input"):
		var input_dir = owner_entity.get_movement_input()
		if input_dir.length() > 0.0:
			return input_dir.normalized()
			
	if owner_entity.velocity.length() > 0.0:
		return owner_entity.velocity.normalized()
		
	return Vector2.RIGHT
	
func _on_finished() -> void:
	owner_entity.velocity = Vector2.ZERO
	print("Finished dashing!")
	
	spawn_shard_at_position(owner_entity.position, base_element)
	
func spawn_shard_at_position(shard_position: Vector2, shard_element: Enums.Elements) -> void:
	if not shard_tscn:
		push_warning("shard scene not assigned")
		return
		
	var shard = shard_tscn.instantiate() as ElementalShard
	shard.setup(shard_position, shard_element)
	get_tree().current_scene.add_child(shard)
	
