class_name PlayerAbilities extends Node

const BOOMERANG = preload("res://Player/boomerang.tscn")
const BOMB = preload("uid://02di3luk3d24")

var abilities : Array[ String ] = [
	"", "", "", "" # BOOMERANG, GRAPPLE, BOW, BOMB
]

var selected_ability : int = 0
var player : Player
var boomerang_instance : Boomerang = null

@onready var state_machine: PlayerStateMachine = $"../StateMachine"
@onready var lift: PlayerState_Lift = $"../StateMachine/Lift"
@onready var idle: PlayerState_Idle = $"../StateMachine/Idle"
@onready var move: PlayerState_Move = $"../StateMachine/Move"
@onready var bow: PlayerState_Bow = $"../StateMachine/Bow"
@onready var grapple: PlayerState_Grapple = $"../StateMachine/Grapple"

func _ready() -> void:
	player = PlayerManager.player
	PlayerHud.update_arrow_count( player.arrow_count )
	PlayerHud.update_bomb_count( player.bomb_count )
	setup_abilities()
	SaveManager.game_loaded.connect( _on_game_loaded )
	PlayerManager.INVENTORY_DATA.ability_acquired.connect( _on_ability_acquired )
	pass


func setup_abilities( select_index : int = 0 ) -> void:
	PauseMenu.update_ability_items( abilities )
	PlayerHud.update_ability_items( abilities )
	selected_ability = select_index - 1
	toggle_ability()
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ability"):
		if abilities.count( "" ) == abilities.size():
			return
			
		match selected_ability:
			0:
				boomerang_ability()
			1:
				grapple_ability()
			2:
				bow_ability()
			3:
				bomb_ability()
	elif event.is_action_pressed("switch_ability"):
		toggle_ability()
	pass


func toggle_ability() -> void:
	if abilities.count( "" ) == abilities.size():
		return
		
	selected_ability = wrapi( selected_ability + 1, 0, abilities.size() )
	while abilities[ selected_ability ] == "":
		selected_ability = wrapi( selected_ability + 1, 0, abilities.size() )
	PlayerHud.update_ability_ui( selected_ability )
	pass


func boomerang_ability() -> void:
	if boomerang_instance != null:
		return
	
	var _b = BOOMERANG.instantiate() as Boomerang
	player.add_sibling( _b )
	_b.global_position = player.global_position
	
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	
	_b.throw( throw_direction )
	boomerang_instance = _b
	pass


func bomb_ability() -> void:
	if player.bomb_count <= 0:
		return
	elif state_machine.current_state == idle or state_machine.current_state == move:
		player.bomb_count -= 1

		lift.start_anim_late = true
		var bomb : Node2D = BOMB.instantiate()
		player.add_sibling( bomb )
		bomb.global_position = player.global_position
		PlayerManager.interact_handled = false
		var throwable : ThrowableBomb = bomb.find_child( "Throwable" )
		throwable.player_interact()
	pass


func bow_ability() -> void:
	if player.arrow_count <= 0:
		return
	elif state_machine.current_state == idle or state_machine.current_state == move:
		player.arrow_count -= 1
		player.state_machine.ChangeState( bow )
		pass
	pass


func grapple_ability() -> void:
	if state_machine.current_state == idle or state_machine.current_state == move:
		player.state_machine.ChangeState( grapple )
		pass
	pass


func _on_game_loaded() -> void:
	var new_abilities = SaveManager.current_save.abilities
	abilities.clear()
	for i in new_abilities:
		abilities.append( i )
	setup_abilities()
	pass


func _on_ability_acquired( _ability : AbilityItemData ) -> void:
	# BOOMERANG, GRAPPLE, ARROW, BOMB
	match _ability.type:
		_ability.Type.BOOMERANG:
			abilities[ 0 ] = "BOOMERANG"
		_ability.Type.GRAPPLE:
			abilities[ 1 ] = "GRAPPLE"
		_ability.Type.ARROW:
			abilities[ 2 ] = "ARROW"
		_ability.Type.BOMB:
			abilities[ 3 ] = "BOMB"
	setup_abilities()
	pass
