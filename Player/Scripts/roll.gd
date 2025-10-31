class_name PlayerState_Roll extends PlayerState

@export var roll_speed : float = 150.0
@export var roll_sound : AudioStream

var rolling: bool = false
var roll_direction: Vector2 = Vector2.ZERO

@onready var idle: PlayerState = $"../Idle"
@onready var move: PlayerState = $"../Move"
@onready var attack: PlayerState = $"../Attack"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var audio: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
var audio_volume : float = -12.0
var from_position : float = 0.4

func Enter() -> void:
	if player.direction != Vector2.ZERO:
		roll_direction = player.direction.normalized()
	else:
		roll_direction = player.cardinal_direction
	
	player.UpdateAnimation("roll")
	animation_player.animation_finished.connect( EndRoll )
	
	var pitch_scale = randf_range( 0.9, 1.2 )
	PlayerManager.play_audio( roll_sound, audio_volume, pitch_scale, from_position )
	
	rolling = true
	pass
		
		
func Exit() -> void:
	animation_player.animation_finished.disconnect( EndRoll )
	pass
	
	
func Process(_delta: float) -> PlayerState:
	player.velocity = roll_direction * roll_speed
	
	if rolling == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return move
	return null


func Physics(_delta: float) -> PlayerState:
	return null
	
	
func HandleInput(_event: InputEvent) -> PlayerState:
	if _event.is_action_pressed("attack"):
		rolling = false
		return attack
	return null


func EndRoll( _new_anim_name : String ) -> void:
	rolling = false
