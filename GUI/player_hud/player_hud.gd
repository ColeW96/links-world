extends CanvasLayer

@export var button_focus_audio : AudioStream = preload("res://title_scene/audio/menu_focus.wav")
@export var button_select_audio : AudioStream = preload("res://title_scene/audio/menu_select.wav")

const TITLE_SCREEN : String = "res://title_scene/title_scene.tscn"

var hearts : Array[ HeartsGUI ] = []


@onready var game_over: Control = $Control/GameOver
@onready var btn_continue: Button = $Control/GameOver/VBoxContainer/btnContinue
@onready var btn_title: Button = $Control/GameOver/VBoxContainer/btnTitle
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var boss_ui: Control = $Control/BossUI
@onready var boss_hp_bar: TextureProgressBar = $Control/BossUI/TextureProgressBar
@onready var boss_label: Label = $Control/BossUI/Label
@onready var notification_popup: NotificationUI = $Control/Notification

@onready var abilities: Control = $Control/Abilities
@onready var ability_items: HBoxContainer = $Control/Abilities/HBoxContainer
@onready var arrow_count_label: Label = %ArrowCountLabel
@onready var bomb_count_label: Label = %BombCountLabel



func _ready() -> void:
	for child in $Control/HFlowContainer.get_children():
		if child is HeartsGUI:
			hearts.append( child )
			child.visible = false
	
	hide_game_over_screen()
	btn_continue.focus_entered.connect( play_audio.bind( button_focus_audio ) )
	btn_continue.pressed.connect( load_game )
	btn_title.focus_entered.connect( play_audio.bind( button_focus_audio ) )
	btn_title.pressed.connect( title_screen )
	LevelManager.level_load_started.connect( hide_game_over_screen )
	LevelManager.level_load_started.connect( hide_boss_health )
	hide_boss_health()
	
	update_ability_ui(0)
	PauseMenu.shown.connect( _on_show_pause )
	PauseMenu.hidden.connect( _on_hide_pause )
	pass
	
	
func update_hp ( _hp: int, _max_hp: int ) -> void:
	update_max_hp( _max_hp )
	for i in _max_hp:
		update_heart( i, _hp )
		pass
	pass


func update_heart( _index: int, _hp: int ) -> void:
	var _value : int = clampi( _hp - _index * 2, 0, 2 )
	hearts[ _index ].value = _value
	pass
	
	
func update_max_hp( _max_hp: int ) -> void:
	var _heart_count : int = roundi( _max_hp * 0.5 )
	for i in hearts.size():
		if i < _heart_count:
			hearts[i].visible = true
		else:
			hearts[i].visible = false
	pass


func show_game_over_screen() -> void:
	hide_boss_health()
	game_over.visible = true
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var can_continue : bool = get_can_continue()
	btn_continue.visible = can_continue
	
	animation_player.play("show_game_over")
	await animation_player.animation_finished
	
	if can_continue == true:
		btn_continue.grab_focus()
	else:
		btn_title.grab_focus()
	pass



func hide_game_over_screen() -> void:
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color(1,1,1,0)
	pass


func play_audio( _a : AudioStream ) -> void:
	audio.stream = _a
	audio.play()
	pass


func load_game() -> void:
	play_audio( button_select_audio )
	await fade_to_black()
	SaveManager.load_game()
	pass


func title_screen() -> void:
	play_audio(button_select_audio)
	await fade_to_black()
	PlayerManager.player_spawned = false
	LevelManager.load_new_level( TITLE_SCREEN, "", Vector2.ZERO )


func fade_to_black() -> bool:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	PlayerManager.player.revive_player()
	await get_tree().process_frame
	await get_tree().process_frame
	return true


func get_can_continue() -> bool:
	var value = SaveManager.current_save.get("player")
	print(value)
	if SaveManager.get_save_file() != null:
		if value["pos_x"] == 0 and value["pos_y"] == 0:
			return false
	return true


func show_boss_health( boss_name : String ) -> void:
	boss_ui.visible = true
	boss_label.text = boss_name
	update_boss_health(1, 1)
	pass


func hide_boss_health() -> void:
	boss_ui.visible = false
	pass


func update_boss_health( hp : int, max_hp : int ) -> void:
	boss_hp_bar.value = clampf( float(hp) / float(max_hp) * 100, 0, 100 )
	pass


func queue_notification( _title : String, _message : String ) -> void:
	notification_popup.add_notification_to_queue( _title, _message )
	pass


func update_ability_items( items : Array[ String ] ) -> void:
	var ability_textures : Array[ Node ] = ability_items.get_children()
	for i in ability_textures.size():
		if items[ i ] == "":
			ability_textures[ i ].visible = false
		else:
			ability_textures[ i ].visible = true
	pass



func update_ability_ui( ability_index : int ) -> void:
	var _items : Array[ Node ] = ability_items.get_children()
	for i in _items:
		i.self_modulate = Color( 1, 1, 1, 0 )
		i.modulate = Color( 0.6, 0.6, 0.6, 0.8 )
	_items[ ability_index ].self_modulate = Color( 1, 1, 1, 1 )
	_items[ ability_index ].modulate = Color( 1, 1, 1, 1 )
	play_audio( button_focus_audio )
	pass


func update_arrow_count( count : int ) -> void:
	arrow_count_label.text = str( count )
	pass


func update_bomb_count( count : int ) -> void:
	bomb_count_label.text = str( count )
	pass


func _on_show_pause() -> void:
	abilities.visible = false
	pass


func _on_hide_pause() -> void:
	abilities.visible = true
	pass
