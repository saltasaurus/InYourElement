class_name Ability
extends Node

signal ability_finished

@export var cooldown_duration: float = 1.0
@export var ability_duration: float = 0.3

var is_active: bool = false
var ability_timer: float = 0.0
var cooldown_timer : float = 0.0


func execute() -> void:
	if not can_execute():
		print("CANT EXECUTE: ", is_active, " | ", cooldown_timer)
		return
		
	is_active = true
	ability_timer = ability_duration
	cooldown_timer = cooldown_duration
	_on_execute()
	
func can_execute() -> bool:
	return cooldown_timer <= 0.0 and not is_active

## Override in child classes for ability specific logic
func _on_execute() -> void:
	pass
	
func _process(delta: float) -> void:
	if is_active:
		ability_timer -= delta
		if ability_timer <= 0.0:
			is_active = false
			ability_finished.emit()
			_on_finished()

	if cooldown_timer > 0.0:
		cooldown_timer -= delta

## Override in child classes for cleanup logic		
func _on_finished() -> void:
	pass
