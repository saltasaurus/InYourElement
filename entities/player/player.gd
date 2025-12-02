class_name Player
extends CharacterBody2D
## Player character controller with state machine, abilities, and elemental infusion system.

# Signals
signal infusion_started(element: Enums.Elements)
signal infusion_ended

# Enums
enum State { IDLE, WALKING, ATTACKING, DASHING }

# Exported variables
@export var movespeed: float = 200.0
@export var slowspeed: float = 50.0
@export var dash_speed: float = 500.0
@export var projectile_spawn_distance := 8.0
@export var infusion_duration: float = 4.0

# Public variables
var current_state: State = State.IDLE
var movement_direction: Vector2 = Vector2.ZERO
var mouse_direction: Vector2 = Vector2.DOWN
var attack_direction: Vector2
var infusion_element: Enums.Elements

# Animation state properties (read by AnimationTree Advance expressions)
var is_attacking: bool = false
var is_dashing: bool = false

# Node references
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var ability_manager: AbilityManager = $AbilityManager
@onready var projectile_tscn: PackedScene = preload("res://combat/projectiles/projectile.tscn")
@onready var projectile_spawnpoint: Marker2D = $ProjectileSpawnpoint
@onready var collection_area: Area2D = $CollectionArea
@onready var _infusion_timer: Timer = $InfusionTimer


#region Built-in Methods

func _ready() -> void:
	animation_tree.active = true
	animation_tree.animation_finished.connect(_on_animation_finished)

	ability_manager.attack_started.connect(_on_attack_started)
	ability_manager.attack_finished.connect(_on_attack_finished)
	ability_manager.dash_started.connect(_on_dash_started)
	ability_manager.dash_finished.connect(_on_dash_finished)

	collection_area.area_entered.connect(_on_collection_area_entered)
	_infusion_timer.timeout.connect(_clear_infusion)
	_infusion_timer.one_shot = true


func _physics_process(_delta: float) -> void:
	_update_state_machine()

	match current_state:
		State.IDLE:
			_handle_idle_state()
		State.WALKING:
			_handle_walking_state()
		State.ATTACKING:
			_handle_attacking_state()
		State.DASHING:
			_handle_dashing_state()

	move_and_slide()
	_update_animation()

#endregion


#region Public Methods

func can_attack() -> bool:
	return current_state in [State.IDLE, State.WALKING]


func can_dash() -> bool:
	return current_state in [State.IDLE, State.WALKING, State.ATTACKING]


func transition_to(next_state: State) -> void:
	if next_state == current_state:
		return

	_exit_state(current_state)
	current_state = next_state
	_enter_state(next_state)


## Returns normalized direction from player to mouse position.
func get_mouse_direction() -> Vector2:
	var mouse_pos := get_global_mouse_position()
	return (mouse_pos - global_position).normalized()

func is_infused() -> bool:
	return infusion_element != Enums.Elements.NONE
#endregion


#region Private Methods

func _update_state_machine() -> void:
	# Handle higher priority inputs first
	if Input.is_action_just_pressed("attack") and can_attack():
		ability_manager.execute_attack()
		return
	if Input.is_action_just_pressed("dash") and can_dash():
		ability_manager.execute_dash()
		return

	# Handle state transitions based on current state
	match current_state:
		State.IDLE:
			if velocity.length() > 0:
				transition_to(State.WALKING)
		State.WALKING:
			if velocity.length() == 0:
				transition_to(State.IDLE)
		State.ATTACKING, State.DASHING:
			pass


## Handle one-time events when entering a state.
func _enter_state(state: State) -> void:
	match state:
		State.ATTACKING:
			is_attacking = true
			attack_direction = get_mouse_direction()
		State.DASHING:
			is_dashing = true
		State.WALKING, State.IDLE:
			pass


## Handle one-time cleanup when exiting a state.
func _exit_state(state: State) -> void:
	match state:
		State.ATTACKING:
			is_attacking = false
		State.DASHING:
			is_dashing = false
		State.WALKING, State.IDLE:
			pass


func _handle_idle_state() -> void:
	_handle_movement_input(movespeed)


func _handle_walking_state() -> void:
	_handle_movement_input(movespeed)


func _handle_attacking_state() -> void:
	_handle_movement_input(0.0)


func _handle_dashing_state() -> void:
	pass


func _handle_movement_input(speed: float) -> void:
	var direction := _get_movement_input()
	velocity = direction * speed


func _get_movement_input() -> Vector2:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return input_direction


func _update_animation() -> void:
	var blend_position_format_string := "parameters/%s/blend_position"
	movement_direction = velocity.normalized()
	mouse_direction = get_mouse_direction()

	animation_tree.set(blend_position_format_string % "Walk", movement_direction)
	animation_tree.set(blend_position_format_string % "Idle", mouse_direction)
	animation_tree.set(blend_position_format_string % "Attack", attack_direction)
		
func _get_projectile_position() -> Vector2:
	var mouse_dir := position - get_global_mouse_position()
	return global_position + (mouse_dir * projectile_spawn_distance)


func _start_infusion(element: Enums.Elements) -> void:
	infusion_element = element
	_infusion_timer.start(infusion_duration)
	infusion_started.emit(element)


func _clear_infusion() -> void:
	infusion_element = Enums.Elements.NONE
	_infusion_timer.stop()
	infusion_ended.emit()

#endregion


#region Signal Callbacks

func _on_animation_finished() -> void:
	pass


func _on_attack_started() -> void:
	transition_to(State.ATTACKING)


func _on_attack_finished() -> void:
	if current_state == State.ATTACKING:
		transition_to(State.IDLE)


func _on_dash_started() -> void:
	transition_to(State.DASHING)


func _on_dash_finished() -> void:
	if current_state == State.DASHING:
		transition_to(State.IDLE)


func _on_collection_area_entered(area: Area2D) -> void:
	if infusion_element != Enums.Elements.NONE:
		return

	if area is ElementalShard and area.is_collectable:
		_start_infusion(area.element)
		area.collect()

#endregion
