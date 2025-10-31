class_name PlayerState_Attack extends PlayerState

var attacking: bool = false
@export_range(1, 20, 0.5) var decelerate_speed: float = 7.0

@export var attack_sound : AudioStream

@onready var idle: PlayerState = $"../Idle"
@onready var move: PlayerState = $"../Move"
@onready var roll: PlayerState = $"../Roll"
@onready var charge_attack: PlayerState = $"../ChargeAttack"
@onready var hurt_box: HurtBox = %AttackHurtBox
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var attack_effect_player: AnimationPlayer = $"../../Sprite2D/AttackEffect/AnimationPlayer"

var audio_volume = -10.0

func Enter() -> void:
	player.UpdateAnimation("attack")
	attack_effect_player.play("attack_" + player.AnimDirection())
	animation_player.animation_finished.connect( EndAttack )
	
	var pitch_scale = randf_range( 0.9, 1.2 )
	PlayerManager.play_audio( attack_sound, audio_volume, pitch_scale )
	attacking = true
	
	await get_tree().create_timer( 0.075 ).timeout
	if attacking:
		hurt_box.monitoring = true
	pass
		
func Exit() -> void:
	animation_player.animation_finished.disconnect( EndAttack )
	hurt_box.monitoring = false
	pass
	
	
func Process(_delta: float) -> PlayerState:
	player.velocity -= player.velocity * decelerate_speed * _delta
	
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return move
	return null


func Physics(_delta: float) -> PlayerState:
	return null
	
	
func HandleInput(_event: InputEvent) -> PlayerState:
	return null


func EndAttack( _new_anim_name : String ) -> void:
	if Input.is_action_pressed("attack"):
		state_machine.ChangeState( charge_attack )
	attacking = false
