class_name DashAbility
extends Ability

@export var dash_speed: float = 500.0
@export var dash_distance: float = 50.0

var owner_entity: CharacterBody2D
var dash_direction: Vector2

func _ready() -> void:
	owner_entity = owner as CharacterBody2D
	ability_duration = dash_distance / dash_speed
	
	cooldown_duration = 3.0
	pickup_cooldown_duration = 3.0

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
	
