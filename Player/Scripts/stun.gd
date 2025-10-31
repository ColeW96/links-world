class_name PlayerState_Stun extends PlayerState

@export var knockback_speed : float = 200.0
@export var decelrate_speed : float = 10.0
@export var invulnerable_duration : float = 1.0

var hurt_box : HurtBox
var direction : Vector2

var next_state : PlayerState = null

@onready var idle: PlayerState = $"../Idle"
@onready var death: PlayerState_Death = $"../Death"


func init() -> void:
	player.player_damaged.connect( _player_damaged )
	pass


func Enter() -> void:
	player.animation_player.animation_finished.connect( _animation_finished )
	
	direction = player.global_position.direction_to( hurt_box.global_position )
	player.velocity = direction * -knockback_speed
	player.SetDirection()
	
	player.UpdateAnimation("stun")
	
	player.make_invulnerable( invulnerable_duration )
	player.effect_animation_player.play("damaged")
	
	PlayerManager.shake_camera()
	pass
		
		
func Exit() -> void:
	next_state = null
	player.animation_player.animation_finished.disconnect( _animation_finished )
	pass
	
	
func Process(_delta: float) -> PlayerState:
	player.velocity -= player.velocity * decelrate_speed * _delta
	return next_state


func Physics(_delta: float) -> PlayerState:
	return null
	
	
func HandleInput(_event: InputEvent) -> PlayerState:
	return null


func _player_damaged( _hurt_box : HurtBox ) -> void:
	hurt_box = _hurt_box
	if state_machine.current_state != death:
		state_machine.ChangeState(self)
	pass


func _animation_finished( _a : String ) -> void:
	next_state = idle
	if player.hp <= 0:
		next_state = death
	pass
