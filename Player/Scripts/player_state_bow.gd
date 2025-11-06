class_name PlayerState_Bow extends PlayerState

const ARROW = preload("uid://cy6xv0xt31w82")

@onready var idle: PlayerState = $"../Idle"

var direction : Vector2 = Vector2.ZERO
var next_state : PlayerState = null

func _ready():
	pass


func Enter() -> void:
	player.UpdateAnimation( "bow" )
	player.animation_player.animation_finished.connect( _on_animation_finished )
	direction = player.cardinal_direction
	
	var arrow : Arrow = ARROW.instantiate()
	player.add_sibling( arrow )
	arrow.global_position = player.global_position + ( direction * 16 )
	arrow.fire( direction )
	pass


func Exit() -> void:
	player.animation_player.animation_finished.disconnect( _on_animation_finished )
	next_state = null
	pass


func Process(_delta: float) -> PlayerState:
	player.velocity = Vector2.ZERO
	return next_state


func Physics(_delta: float) -> PlayerState:
	return null


func HandleInput(_event: InputEvent) -> PlayerState:
	return null


func _on_animation_finished( _anim_name : String ) -> void:
	next_state = idle
	pass
