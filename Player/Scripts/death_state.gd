class_name PlayerState_Death extends PlayerState

@export var exhaust_audio : AudioStream

@onready var audio: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
@onready var idle: PlayerState_Idle = $"../Idle"


func _ready():
	pass
	

func init() -> void:
	pass


func Enter() -> void:
	player.animation_player.play( "death" )
	audio.stream = exhaust_audio
	audio.pitch_scale = 2.5
	audio.play()
	PlayerHud.show_game_over_screen()
	AudioManager.play_music( null )
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
