class_name PlayerState_Carry extends PlayerState

@export var move_speed : float = 80.0
@export var throw_audio : AudioStream

var moving : bool = false
var throwable : Throwable

@onready var idle: PlayerState_Idle = $"../Idle"
@onready var stun: PlayerState_Stun = $"../Stun"



func _ready():
	pass
	

func init() -> void:
	pass


func Enter() -> void:
	player.UpdateAnimation( "carry" )
	moving = false
	pass
		
		
func Exit() -> void:
	
	if throwable:
		if player.direction == Vector2.ZERO:
			throwable.throw_direction = player.cardinal_direction
		else:
			throwable.throw_direction = player.direction
		
		if state_machine.next_state == stun:
			throwable.throw_direction = throwable.throw_direction.rotated( PI )
			throwable.drop()
		else:
			player.audio.stream = throw_audio
			player.audio.play()
			throwable.throw()
	pass
	
	
func Process(_delta: float) -> PlayerState:
	if moving == true and player.animation_player.current_animation != "carry_move_" + player.AnimDirection():
		player.SetDirection()
		player.UpdateAnimation( "carry_move" )
	
	if player.direction == Vector2.ZERO:
		moving = false
		player.UpdateAnimation( "carry" )
	elif player.SetDirection() or moving == false:
		player.UpdateAnimation( "carry_move" )
		moving = true
		
	player.velocity = player.direction * move_speed
	return null


func Physics(_delta: float) -> PlayerState:
	return null
	
	
func HandleInput(_event: InputEvent) -> PlayerState:
	if _event.is_action_pressed("attack") or _event.is_action_pressed("interact"):
		return idle
	return null
