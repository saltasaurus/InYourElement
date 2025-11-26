extends CharacterBody2D

@export var max_health: float = 50.0

var current_health: float

@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	current_health = max_health
	
	hurtbox.damage_taken.connect(_on_damage_taken)
	
func _on_damage_taken(damage: float, element: Enums.Elements) -> void:
	print("Took ", damage, " ", str(Enums.Elements.keys()[element]).to_lower(), " damage")
	current_health -= damage
	print("Health at ", current_health)
	
	if current_health <= 0:
		print("DEAD")
		queue_free()
		
