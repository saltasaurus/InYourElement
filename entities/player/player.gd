class_name Player
extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var ability_manager := $AbilityManager
@onready var projectile_tscn = preload("res://combat/projectiles/projectile.tscn")
@onready var projectile_spawnpoint := $ProjectileSpawnpoint
@onready var collection_area  := $CollectionArea

@export var movespeed: float = 200.0
@export var slowspeed: float = 50.0
@export var dash_speed: float = 500.0
@export var projectile_spawn_distance := 8.0

var is_attacking: bool = false
var is_dashing: bool = false

var current_state: State = State.IDLE
var movement_direction: Vector2 = Vector2.ZERO
var mouse_direction: Vector2 = Vector2.DOWN
var attack_direction: Vector2
var infusion_element: Enums.Elements

enum State { IDLE, WALKING, ATTACKING, DASHING }

func _ready():
	animation_tree.active = true
	animation_tree.animation_finished.connect(_on_animation_finished)
	
	ability_manager.attack_started.connect(_on_attack_started)
	ability_manager.attack_finished.connect(_on_attack_finished)
	
	ability_manager.dash_started.connect(_on_dash_started)
	ability_manager.dash_finished.connect(_on_dash_finished)
	
	collection_area.area_entered.connect(_on_collection_area_entered)

func _get_projectile_position() -> Vector2:
	var mouse_dir = (position - get_global_mouse_position())
	return global_position + (mouse_dir * projectile_spawn_distance)

func _physics_process(_delta: float) -> void:
	# Check for state transitions
	update_state_machine()
	
	# Handle state
	match current_state:
		State.IDLE:
			handle_idle_state()
		State.WALKING:
			handle_walking_state()
		State.ATTACKING:
			handle_attacking_state()
		State.DASHING:
			handle_dashing_state()
			
	#print("Velocity = ", velocity)
	# Velocity determined by state handlers
	move_and_slide()
	
	# Advance Expressions and blend positions calculated during state handlers
	update_animation()
	
func update_state_machine() -> void:
	
	# Handle higher priority inputs
	if Input.is_action_just_pressed("attack") and can_attack():
		ability_manager.execute_attack()
		return
	if Input.is_action_just_pressed("dash") and can_dash():
		ability_manager.execute_dash()
		return
		
	match current_state:
		State.IDLE:
			if velocity.length() > 0:
				transition_to(State.WALKING)
		State.WALKING:
			if velocity.length() == 0:
				transition_to(State.IDLE)
		State.ATTACKING:
			pass
		State.DASHING:
			pass
				
func transition_to(next_state: State):
	if next_state == current_state:
		return
		
	# Handle events at end of state
	_exit_state(current_state)
	
	current_state = next_state
	
	_enter_state(next_state)
	
	print("State transition: ", State.keys()[next_state])

## Handle one-time interactions when exiting a state
func _exit_state(state: State) -> void:
	match state:
		State.ATTACKING:
			is_attacking = false
		State.DASHING:
			is_dashing = false
		State.WALKING, State.IDLE:
			pass
	
## Handle one-time interactions when entering a state
func _enter_state(state: State) -> void:
	match state:
		State.ATTACKING:
			is_attacking = true
			infusion_element = Enums.Elements.NONE
			attack_direction = get_mouse_direction()
		State.DASHING:
			is_dashing = true
		State.WALKING, State.IDLE:
			pass

func can_attack() -> bool:
	return current_state in [State.IDLE, State.WALKING]
	
func can_dash() -> bool:
	return current_state in [State.IDLE, State.WALKING, State.ATTACKING]
	
func handle_idle_state() -> void:
	
	handle_movement_input(movespeed)	
	
func handle_walking_state() -> void:
	is_attacking = false
	is_dashing = false
	
	handle_movement_input(movespeed)	
	
func handle_attacking_state() -> void:
	# Prevent movement during attacks -> TODO -- maybe reduce velocity
	#velocity = Vector2.ZERO
	
	is_dashing = false
	
	handle_movement_input(0.0)
	
func handle_dashing_state() -> void:
	is_attacking = false
	
	#handle_movement_input(dash_speed)

func handle_movement_input(speed: float):
	var direction = get_movement_input()
	velocity = direction * speed
	
func get_movement_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return input_direction
	
func get_mouse_direction():
	var mouse_pos = get_global_mouse_position()
	return (mouse_pos - global_position).normalized()
		
func update_animation():
	var blend_position_format_string = "parameters/%s/blend_position"
	var move_direction = velocity.normalized()
	mouse_direction = get_mouse_direction()
	
	animation_tree.set(blend_position_format_string % "Walk", move_direction)
	animation_tree.set(blend_position_format_string % "Idle", mouse_direction)
	animation_tree.set(blend_position_format_string % "Attack", attack_direction)

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
	if area is ElementalShard and infusion_element == Enums.Elements.NONE:
		infusion_element = area.element
		area.collect()
		print("Infused with: ", Enums.get_element_string(infusion_element))
