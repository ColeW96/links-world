extends CanvasLayer

const TITLE_SCREEN : String = "res://title_scene/title_scene.tscn"


signal shown
signal hidden

@onready var audio_stream_player: AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var tab_container: TabContainer = $Control/TabContainer
@onready var btn_save: Button = $Control/TabContainer/System/VBoxContainer/btn_save
@onready var btn_load: Button = $Control/TabContainer/System/VBoxContainer/btn_load
@onready var btn_title: Button = $Control/TabContainer/System/VBoxContainer/btn_title
@onready var btn_quit: Button = $Control/TabContainer/System/VBoxContainer/btn_quit
@onready var item_description: Label = $Control/TabContainer/Inventory/ItemDescription

var is_paused : bool = false

func _ready() -> void:
	hide_pause_menu()
	btn_save.pressed.connect( _on_save_pressed )
	btn_load.pressed.connect( _on_load_pressed )
	btn_title.pressed.connect( _on_title_pressed )
	btn_quit.pressed.connect( _on_quit_pressed )
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			if DialogSystem.is_active:
				return
			if PlayerManager.player.state_machine.get_current_state() == PlayerManager.player.death:
				return
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()
		
	if is_paused:
		if event.is_action_pressed("right_bumper"):
			change_tab( 1 )
		elif event.is_action_pressed("left_bumper"):
			change_tab( -1 )
		

func show_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	tab_container.current_tab = 0
	shown.emit()


func hide_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()


func _on_save_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.save_game()
	btn_load.disabled = false
	btn_load.visible = true
	hide_pause_menu()
	pass
	
	
func _on_load_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.load_game()
	await LevelManager.level_load_started
	hide_pause_menu()
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()


func update_item_description( new_text : String ) -> void:
	await get_tree().process_frame
	item_description.text = new_text
	pass


func play_audio( audio : AudioStream ) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()


func change_tab( _i : int = 1 ) -> void:
	tab_container.current_tab = wrapi(
			tab_container.current_tab + _i,
			0,
			tab_container.get_tab_count()
		)
	tab_container.get_tab_bar().grab_focus()
	pass


func _on_title_pressed() -> void:
	PlayerManager.player_spawned = false
	hide_pause_menu()
	LevelManager.load_new_level( TITLE_SCREEN, "", Vector2.ZERO )
	pass
