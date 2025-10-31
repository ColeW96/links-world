class_name PlayerState_ChargeAttack extends PlayerState

@export var charge_duration : float = 1.0
@export var move_speed : float = 80.0
@export var sfx_charged : AudioStream
@export var sfx_spin : AudioStream

var timer : float = 0.0
var moving : bool = false
var is_attacking : bool = false
var particles : ParticleProcessMaterial

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var idle: PlayerState_Idle = $"../Idle"
@onready var charge_hurt_box: HurtBox = %ChargeHurtBox
@onready var charge_spin_hurt_box: HurtBox = %ChargeSpinHurtBox
@onready var audio_stream_player: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
@onready var spin_effect_sprite: Sprite2D = $"../../Sprite2D/SpinEffect"
@onready var spin_effect_player: AnimationPlayer = $"../../Sprite2D/SpinEffect/AnimationPlayer"
@onready var gpu_particles: GPUParticles2D = $"../../Sprite2D/ChargeSpinHurtBox/GPUParticles2D"



func _ready():
	pass
	

func init() -> void:
	gpu_particles.emitting = false
	particles = gpu_particles.process_material as ParticleProcessMaterial
	spin_effect_sprite.visible = false
	pass


func Enter() -> void:
	timer = charge_duration
	is_attacking = false
	moving = false
	charge_hurt_box.monitoring = false
	gpu_particles.emitting = true
	gpu_particles.amount = 4
	gpu_particles.explosiveness = 0
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30
	pass
		
		
func Exit() -> void:
	charge_hurt_box.monitoring = false
	charge_spin_hurt_box.monitoring = false
	spin_effect_sprite.visible = false
	gpu_particles.emitting = false
	pass
	
	
func Process(_delta: float) -> PlayerState:
	if timer > 0:
		timer -= _delta
		if timer <= 0:
			timer = 0
			charge_complete()
	
	if is_attacking == false:
		if moving == true and player.animation_player.current_animation != "charge_move_" + player.AnimDirection():
			player.SetDirection()
			player.UpdateAnimation( "charge_move" )
		
		if player.direction == Vector2.ZERO:
			moving = false
			player.UpdateAnimation( "charge" )
		elif player.SetDirection() or moving == false:
			moving = true
			player.UpdateAnimation( "charge_move" )
	player.velocity = player.direction * move_speed
	return null


func Physics(_delta: float) -> PlayerState:
	return null
	
	
func HandleInput(_event: InputEvent) -> PlayerState:
	if _event.is_action_released("attack"):
		if timer > 0:
			return idle
		elif is_attacking == false:
			charge_attack()
	return null


func charge_attack() -> void:
	gpu_particles.emitting = false
	is_attacking = true
	player.animation_player.play( "charge_attack" )
	player.animation_player.seek( get_spin_frame() )
	play_audio( sfx_spin )
	spin_effect_sprite.visible = true
	spin_effect_player.play("spin")
	var _duration : float = player.animation_player.current_animation_length
	player.make_invulnerable( _duration )
	charge_spin_hurt_box.monitoring = true
	await get_tree().create_timer( _duration * 0.875 ).timeout
	state_machine.ChangeState( idle )
	pass


func get_spin_frame() -> float:
	var interval : float = 0.05
	match player.cardinal_direction:
		Vector2.DOWN:
			return interval * 0
		Vector2.UP:
			return interval * 4
		Vector2.RIGHT:
			return interval * 6
		Vector2.LEFT:
			return interval * 2
		_:
			return interval


func charge_complete() -> void:
	play_audio( sfx_charged )
	gpu_particles.amount = 50
	gpu_particles.explosiveness = 1
	particles.initial_velocity_min = 20
	particles.initial_velocity_max = 30
	await get_tree().create_timer( 0.5 ).timeout
	gpu_particles.amount = 10
	gpu_particles.explosiveness = 0
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30
	pass


func play_audio( _audio : AudioStream ) -> void:
	audio_stream_player.stream = _audio
	audio_stream_player.pitch_scale = 1.0
	audio_stream_player.play()
	pass
