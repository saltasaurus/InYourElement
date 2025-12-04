class_name AbilityManager
extends Node

signal attack_started
signal attack_finished
signal dash_started
signal dash_finished
signal shield_started
signal shield_finished

@onready var sword_ability: SwordAbility = $SwordAbility
@onready var dash_ability: DashAbility = $DashAbility
@onready var shield_ability: ShieldAbility = $ShieldAbility

func _ready() -> void:
	sword_ability.ability_finished.connect(_on_sword_finished)
	dash_ability.ability_finished.connect(_on_dash_finished)
	shield_ability.ability_finished.connect(_on_shield_finished)

func execute_attack() -> void:
	if sword_ability.can_execute():
		sword_ability.execute()
		attack_started.emit()

func execute_dash() -> void:
	if dash_ability.can_execute():
		dash_ability.execute()
		dash_started.emit()

func execute_shield() -> void:
	if shield_ability.can_execute():
		shield_ability.execute()
		shield_started.emit()

func _on_sword_finished() -> void:
	attack_finished.emit()

func _on_dash_finished() -> void:
	dash_finished.emit()

func _on_shield_finished() -> void:
	shield_finished.emit()
