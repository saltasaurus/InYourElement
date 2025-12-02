class_name SwordAbility
extends Ability

@export var projectile_speed: float = 100.0
@export var projectile_damage: float = 10.0
@export var projectile_scene: PackedScene
@export var base_element: Enums.Elements

var owner_entity: Node2D

func _ready() -> void:
	owner_entity = owner as Node2D
	
func _on_execute() -> void:
	spawn_projectile()
	
func spawn_projectile() -> void:
	if not projectile_scene or not owner_entity:
		push_error("SwordAbility: Missing projectile scene or owner entity")
		return

	var projectile = projectile_scene.instantiate() as Projectile

	projectile.global_position = owner_entity.global_position

	projectile.setup(
		_get_fire_direction(),
		projectile_speed,
		projectile_damage,
		get_projectile_element(),
		base_element
		)

	# Only spawn shards from non-infused (base element) projectiles
	projectile.can_spawn_shard = not owner_entity.is_infused()

	_add_projectile_to_scene(projectile)

func _get_fire_direction():
	if owner_entity.has_method("get_mouse_direction"):
		return owner_entity.get_mouse_direction()
	return Vector2.RIGHT

## Returns ability element or infusion if possible
func get_projectile_element() -> Enums.Elements:
	var player_infusion: Enums.Elements = owner_entity.infusion_element
	var infused_element := ElementalManager.get_result_element(base_element, player_infusion)
	return infused_element
	
func _add_projectile_to_scene(projectile):
	get_tree().current_scene.add_child(projectile)
	
