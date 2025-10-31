class_name PlayerState_Lift extends PlayerState

@export var lift_audio : AudioStream

@onready var carry: PlayerState = $"../Carry"


func _ready():
	pass
	


func Enter() -> void:
	player.UpdateAnimation( "lift" )
	player.animation_player.animation_finished.connect( state_complete )
	player.audio.stream = lift_audio
	player.audio.pitch_scale = 2.5
	player.audio.play()
	pass


func Exit() -> void:
	pass


func Process(_delta: float) -> PlayerState:
	player.velocity = Vector2.ZERO
	return null


func Physics(_delta: float) -> PlayerState:
	return null


func HandleInput(_event: InputEvent) -> PlayerState:
	return null


func state_complete( _a : String ) -> void:
	player.animation_player.animation_finished.disconnect( state_complete )
	state_machine.ChangeState( carry )
	pass
