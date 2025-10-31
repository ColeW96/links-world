extends Node

const PLAYER = preload("uid://ck1nuiykmmpqw")
const INVENTORY_DATA : InventoryData = preload("res://GUI/pause_menu/Inventory/player_inventory.tres")

signal camera_shook( trauma : float )
signal interact_pressed
signal player_leveled_up

var interact_handled : bool = true
var player : Player
var player_spawned : bool = false

var level_requirements = [ 0, 50, 100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600 ]

func _ready() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true


func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child( player )
	pass
	

func set_health( hp: int, max_hp: int ) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp( 0 )
	pass


func reward_xp( _xp : int ) -> void:
	player.xp += _xp
	# check for level advancement
	if player.xp >= level_requirements[ player.level ]:
		player.level += 1
		player.attack += 1
		player.defense += 1
		player_leveled_up.emit()


func set_player_position( _new_pos : Vector2 ) -> void:
	player.global_position = _new_pos
	pass


func set_as_parent( _p : Node2D ) -> void:
	if player.get_parent():
		player.get_parent().remove_child( player )
	_p.add_child( player )
	pass
	
	
func unparent_player( _p : Node2D ) -> void:
	_p.remove_child( player )
	pass


func play_audio( audio : AudioStream,
	 			 volume : float = 0.0,
	 			 pitch_scale : float = 1.0,
				 from_position : float = 0.0 ) -> void:
	player.audio.stream = audio
	player.audio.volume_db = volume
	player.audio.pitch_scale = pitch_scale
	player.audio.play( from_position )
	pass


func interact() -> void:
	interact_handled = false
	interact_pressed.emit()
	pass


func shake_camera( trauma : float = 1.0 ) -> void:
	camera_shook.emit( clamp( trauma, 0, 2 ) )
