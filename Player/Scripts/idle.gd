class_name PlayerState_Idle extends PlayerState

@onready var move: PlayerState = $"../Move"
@onready var roll: PlayerState = $"../Roll"
@onready var attack: PlayerState = $"../Attack"
@onready var dash: PlayerState = $"../Dash"

func Enter() -> void:
	player.UpdateAnimation("idle")
	pass
		
		
func Exit() -> void:
	pass
	
	
func Process(_delta: float) -> PlayerState:
	if player.direction != Vector2.ZERO:
		return move
	player.velocity = Vector2.ZERO
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
