class_name Player extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
const DIR_4 : Array[ Vector2 ] = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]
var direction : Vector2 = Vector2.ZERO
var last_facing_direction: Vector2 = Vector2.DOWN

var invulnerable : bool = false
var hp : int = 6
var max_hp : int = 6

var level : int = 1
var xp : int = 0

var attack : int = 1 :
	set( v ):
		attack = v
		update_damage_values()

var defense : int = 1

@onready var lift: PlayerState_Lift = $StateMachine/Lift
@onready var carry: PlayerState_Carry = $StateMachine/Carry
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var hit_box: HitBox = $HitBox
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var held_item: Node2D = $Sprite2D/HeldItem

@onready var death: PlayerState_Death = $StateMachine/Death

signal DirectionChanged( new_direction : Vector2 )
signal player_damaged( hurt_box : HurtBox )

func _ready():
	PlayerManager.player = self
	state_machine.Initialize(self)
	hit_box.Damaged.connect( _take_damage )
	update_hp(99)
	update_damage_values()
	PlayerManager.player_leveled_up.connect( update_damage_values )
	pass
	
	
func _process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	direction = input_direction.normalized()
	
	if direction != Vector2.ZERO:
		last_facing_direction = direction
		SetDirection()
	pass
	

func _physics_process(_delta):
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		#PlayerManager.shake_camera()
		#update_hp(-99)
		#player_damaged.emit( %AttackHurtBox )
		return
	pass


func SetDirection() -> bool:
	if direction == Vector2.ZERO:
		return false
		
	var direction_id : int = int( round( ( direction + cardinal_direction * 0.1 ).angle() / TAU * DIR_4.size() ) )
	var new_dir = DIR_4[ direction_id ]
	
	if abs(direction.x) > abs(direction.y):
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	else:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
		
		
	if new_dir == cardinal_direction:
		return false
		
	cardinal_direction = new_dir
	DirectionChanged.emit( cardinal_direction )
	return true
	
func UpdateAnimation (state: String) -> void:
	animation_player.play(state + "_" + AnimDirection())
	pass
	
	
func AnimDirection() -> String:
	match cardinal_direction:
		Vector2.UP: return "up"
		Vector2.DOWN: return "down"
		Vector2.LEFT: return "left"
		Vector2.RIGHT: return "right"
		_: return "down"


func _take_damage( hurt_box : HurtBox ) -> void:
	if invulnerable == true:
		return
		
	if hp > 0:
		var damage : int = hurt_box.damage
		
		if damage > 0:
			damage = clampi( damage - defense, 1, damage )
		
		update_hp( -damage )
		player_damaged.emit( hurt_box )
	pass
	
	
func update_hp( delta : int ) -> void:
	hp = clampi( hp + delta, 0, max_hp )
	PlayerHud.update_hp( hp, max_hp )
	pass
	
	
func make_invulnerable( _duration : float = 1.0 ) -> void:
	invulnerable = true
	hit_box.monitoring = false
	
	await get_tree().create_timer( _duration ).timeout
	
	invulnerable = false
	hit_box.monitoring = true
	pass


func pickup_item( _t : Throwable ) -> void:
	state_machine.ChangeState( lift )
	carry.throwable = _t
	pass


func revive_player() -> void:
	update_hp(99)
	state_machine.ChangeState( $StateMachine/Idle )
	pass


func update_damage_values() -> void:
	%AttackHurtBox.damage = attack
	%ChargeSpinHurtBox.damage = attack + 1
	pass
