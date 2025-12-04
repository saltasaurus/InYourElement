class_name ShieldAbility
extends Ability

@export var base_element: Enums.Elements = Enums.Elements.EARTH
@export var shard_tscn: PackedScene
@export var shield_scene: PackedScene

var owner_entity: Node2D
var active_shield: Shield

func _ready() -> void:
	owner_entity = owner as Node2D

func _on_execute() -> void:
	spawn_shield()
	print("Shield activated!")

func _on_finished() -> void:
	# Spawn shard at shield position when shield ends
	spawn_shard_at_position(active_shield.global_position, base_element)
	despawn_shield()
	print("Shield deactivated!")

func spawn_shield() -> void:
	if not shield_scene or not owner_entity:
		push_error("ShieldAbility: Missing shield scene or owner entity")
		return

	active_shield = shield_scene.instantiate() as Shield
	#active_shield.global_position = owner_entity.global_position
	owner_entity.add_child(active_shield)

func despawn_shield() -> void:
	if active_shield:
		active_shield.queue_free()
		active_shield = null

func spawn_shard_at_position(shard_position: Vector2, shard_element: Enums.Elements) -> void:
	if not shard_tscn:
		push_warning("shard scene not assigned")
		return

	var shard = shard_tscn.instantiate() as ElementalShard
	shard.setup(shard_position, shard_element)
	get_tree().current_scene.add_child(shard)
