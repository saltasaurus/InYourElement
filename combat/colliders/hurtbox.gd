class_name Hurtbox
extends Area2D

signal damage_taken(amount: float, element: Enums.Elements)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	if area is Projectile:
		print("Hit by projectile")
		damage_taken.emit(area.damage, area.element)
	else:
		print("Area was a ", typeof(area))
