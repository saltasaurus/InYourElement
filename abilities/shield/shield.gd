class_name Shield
extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if animated_sprite:
		animated_sprite.play("default")

func _on_area_entered(area: Area2D) -> void:
	# Destroy enemy projectiles that hit the shield
	if area.get_parent() is Projectile:
		var projectile = area.get_parent() as Projectile
		print("Shield blocked projectile!")
		projectile.queue_free()
