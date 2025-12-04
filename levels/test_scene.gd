extends Node2D

@onready var player: Player = $Player
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	hud.setup(player)
