class_name Plant extends Node2D

signal plant_damaged( hurt_box : HurtBox )
signal plant_destroyed( hurt_box : HurtBox )

var player : Player
var invulnerable : bool = false

@onready var state_machine: PlantStateMachine = $PlantStateMachine
@onready var hit_box: HitBox = $HitBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var hp : int = 1

func _ready() -> void:
	state_machine.initialize( self )
	player = PlayerManager.player
	hit_box.Damaged.connect( _take_damage )
	pass
	
	

func update_animation( state: String ) -> void:
	animation_player.play(state + "_down" )
	pass


func _take_damage( hurt_box : HurtBox ) -> void:
	if invulnerable == true:
		return
	hp -= hurt_box.damage
	if hp > 0:
		plant_damaged.emit( hurt_box )
	else:
		plant_destroyed.emit( hurt_box )
