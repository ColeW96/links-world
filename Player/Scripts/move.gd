class_name PlayerState_Move extends PlayerState

@export var move_speed : float = 100.0
@onready var idle: PlayerState = $"../Idle"
@onready var roll: PlayerState = $"../Roll"
@onready var attack: PlayerState = $"../Attack"
@onready var dash: PlayerState = $"../Dash"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func Enter() -> void:
	player.UpdateAnimation("move")
	pass
		
		
func Exit() -> void:
	pass
	
	
func Process(_delta: float) -> PlayerState:
	if player.direction == Vector2.ZERO:
		return idle
		
	player.velocity = player.direction * move_speed
	player.SetDirection()
	
	if not player.animation_player.is_playing() or player.animation_player.current_animation != "move_" + player.AnimDirection():
		player.UpdateAnimation("move")
		
	return null


func Physics(_delta: float) -> PlayerState:
	return null
	
	
func HandleInput(_event: InputEvent) -> PlayerState:
	if _event.is_action_pressed("roll"):
		return roll
	elif _event.is_action_pressed("attack"):
		return attack
	elif _event.is_action_pressed("interact"):
		PlayerManager.interact()
	elif _event.is_action_pressed("dash"):
		return dash
	return null
