extends CanvasLayer

@onready var attack_cooldown: ProgressBar = $MarginContainer/VBoxContainer/Abilities/VBoxContainer/AttackCooldown
@onready var dash_cooldown: ProgressBar = $MarginContainer/VBoxContainer/Abilities/VBoxContainer2/DashCooldown
@onready var shield_cooldown: ProgressBar = $MarginContainer/VBoxContainer/Abilities/VBoxContainer3/ShieldCooldown

@onready var infusion_panel: PanelContainer = $MarginContainer/VBoxContainer/InfusionPanel
@onready var infusion_label: Label = $MarginContainer/VBoxContainer/InfusionPanel/HBoxContainer/InfusionLabel
@onready var infusion_timer_label: Label = $MarginContainer/VBoxContainer/InfusionPanel/HBoxContainer/TimerLabel
@onready var infusion_color_rect: ColorRect = $MarginContainer/VBoxContainer/InfusionPanel/HBoxContainer/ColorRect

var player: Player
var infusion_time_remaining: float = 0.0

func _ready() -> void:
	infusion_panel.visible = false

func setup(player_node: Player) -> void:
	player = player_node

	# Connect to player signals
	player.infusion_started.connect(_on_infusion_started)
	player.infusion_ended.connect(_on_infusion_ended)

func _process(_delta: float) -> void:
	if not player:
		return

	# Update ability cooldowns
	_update_cooldown_bar(attack_cooldown, player.ability_manager.sword_ability)
	_update_cooldown_bar(dash_cooldown, player.ability_manager.dash_ability)
	_update_cooldown_bar(shield_cooldown, player.ability_manager.shield_ability)

	# Update infusion timer
	if player.is_infused():
		infusion_time_remaining = player._infusion_timer.time_left
		infusion_timer_label.text = "%.1f s" % infusion_time_remaining

func _update_cooldown_bar(bar: ProgressBar, ability: Ability) -> void:
	if ability.cooldown_timer > 0:
		bar.value = (1.0 - (ability.cooldown_timer / ability.cooldown_duration)) * 100.0
	else:
		bar.value = 100.0

func _on_infusion_started(element: Enums.Elements) -> void:
	infusion_panel.visible = true
	infusion_label.text = _get_element_name(element)
	infusion_color_rect.color = ElementalManager.get_element_color(element)

func _on_infusion_ended() -> void:
	infusion_panel.visible = false

func _get_element_name(element: Enums.Elements) -> String:
	match element:
		Enums.Elements.FIRE:
			return "Fire"
		Enums.Elements.WATER:
			return "Water"
		Enums.Elements.EARTH:
			return "Earth"
		Enums.Elements.AIR:
			return "Air"
		Enums.Elements.STEAM:
			return "Steam"
		Enums.Elements.EMBER:
			return "Ember"
		Enums.Elements.SMOKE:
			return "Smoke"
		Enums.Elements.MUD:
			return "Mud"
		Enums.Elements.MIST:
			return "Mist"
		Enums.Elements.DUST:
			return "Dust"
		_:
			return "None"
