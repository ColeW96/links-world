extends Node2D

signal new_game_started

const START_LEVEL : String = "res://Levels/LinksHouse/links_house.tscn"

var can_continue : bool = false

@export var music : AudioStream
@export var button_focus_audio : AudioStream
@export var button_pressed_audio : AudioStream

@onready var button_new: Button = $CanvasLayer/Control/VBoxContainer/ButtonNew
@onready var button_continue: Button = $CanvasLayer/Control/VBoxContainer/ButtonContinue
@onready var button_quit: Button = $CanvasLayer/Control/VBoxContainer/ButtonQuit
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player_spawn: Node2D = $PlayerSpawn
@onready var over_write_save: ColorRect = $CanvasLayer/Control/OverWriteSave
@onready var btn_accept: Button = $CanvasLayer/Control/OverWriteSave/VBoxContainer/btnAccept
@onready var btn_cancel: Button = $CanvasLayer/Control/OverWriteSave/VBoxContainer/btnCancel


func _ready() -> void:
	PlayerManager.set_as_parent(self)
	PlayerManager.player.process_mode = Node.PROCESS_MODE_DISABLED
	PlayerManager.player.visible = false
	PlayerHud.visible = false
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	
	hide_overwrite_popup()
	
	can_continue = get_can_continue()
	
	if can_continue == false:
		button_continue.disabled = true
		button_continue.visible = false
	
	$CanvasLayer/SplashScene.finished.connect( setup_title_screen )
	
	LevelManager.level_load_started.connect( exit_title_screen )
	new_game_started.connect( clear_inventory_on_new_game )
	new_game_started.connect( _hide_pause_menu_load )
	pass



func setup_title_screen() -> void:
	$CanvasLayer/SplashScene.queue_free()
	button_new.pressed.connect( show_overwrite_popup )
	button_continue.pressed.connect( load_game )
	button_quit.pressed.connect( quit_game )
	button_new.grab_focus()
	
	button_new.focus_entered.connect( play_audio.bind( button_focus_audio ) )
	button_continue.focus_entered.connect( play_audio.bind( button_focus_audio ) )
	
	AudioManager.play_music( music, 10 )
	pass


func new_game() -> void:
	SaveManager.new_game()
	hide_overwrite_popup()
	PlayerManager.player_spawned = false
	unpause_player()
	new_game_started.emit()
	LevelManager.load_new_level( START_LEVEL, "", Vector2.ZERO )
	pass


func _hide_pause_menu_load() -> void:
	PauseMenu.btn_load.disabled = true
	PauseMenu.btn_load.visible = false


func clear_inventory_on_new_game() -> void:
	var inventory : InventoryData = PlayerManager.INVENTORY_DATA
	var inventory_slots : Array[ SlotData ] = inventory.inventory_slots()
	for slot in inventory_slots:
		if slot:
			slot.item_data = ItemData.new()
			slot.quantity = 0
	pass


func load_game() -> void:
	play_audio( button_pressed_audio )
	unpause_player()
	SaveManager.load_game()
	pass


func quit_game() -> void:
	get_tree().quit()
	pass


func exit_title_screen() -> void:
	PlayerManager.player.visible = true
	PlayerHud.visible = true
	PlayerManager.unparent_player(self)
	PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	self.queue_free()
	pass


func play_audio( _a : AudioStream ) -> void:
	audio_stream_player.stream = _a
	audio_stream_player.play()
	pass


func unpause_player() -> void:
	PlayerManager.player.process_mode = Node.PROCESS_MODE_INHERIT
	pass


func hide_overwrite_popup() -> void:
	over_write_save.visible = false
	button_new.disabled = false
	button_new.visible = true
	if can_continue == true:
		button_continue.disabled = false
		button_continue.visible = true
	button_quit.disabled = false
	button_quit.visible = true
	button_new.grab_focus()
	pass


func show_overwrite_popup() -> void:
	if SaveManager.get_save_file() == null or can_continue == false:
		new_game()
		return
		
	over_write_save.visible = true
	button_new.disabled = true
	button_new.visible = false
	button_continue.disabled = true
	button_continue.visible = false
	button_quit.disabled = true
	button_quit.visible = false
	btn_accept.pressed.connect( new_game )
	btn_cancel.pressed.connect( hide_overwrite_popup )
	btn_accept.grab_focus()
	pass


func get_can_continue() -> bool:
	if SaveManager.get_save_file() == null:
		return false
	
	var file := SaveManager.get_save_file()
	var json := JSON.new()
	json.parse( file.get_line() )
	var save_dict : Dictionary = json.get_data() as Dictionary
	SaveManager.current_save = save_dict
	var value : Dictionary = SaveManager.current_save.get("player")
	if value["pos_x"] == 0 and value["pos_y"] == 0:
			return false
			
	return true
