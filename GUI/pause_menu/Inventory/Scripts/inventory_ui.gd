class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GUI/pause_menu/Inventory/inventory_slot.tscn")

var focus_index : int = 0
var hovered_item : InventorySlotUI
var swap_item : InventorySlotUI
var focus_item : InventorySlotUI

var swapping : bool = false

@export var data : InventoryData

@onready var inventory_slot_armor: InventorySlotUI = %InventorySlot_Armor
@onready var inventory_slot_amulet: InventorySlotUI = %InventorySlot_Amulet
@onready var inventory_slot_weapon: InventorySlotUI = %InventorySlot_Weapon
@onready var inventory_slot_ring: InventorySlotUI = %InventorySlot_Ring

func _ready() -> void:
	PauseMenu.shown.connect( update_inventory )
	PauseMenu.hidden.connect( clear_inventory )
	clear_inventory()
	data.changed.connect( on_inventory_changed )
	data.equipment_changed.connect( on_inventory_changed )
	pass


func _unhandled_input(event: InputEvent) -> void:
	if PauseMenu.is_paused == true:
		if event.is_action_pressed("ability"):
			if swapping == false:
				swap_item = focus_item
				
				if swap_item.slot_data == null:
					return
				
				swap_item.texture_rect.modulate.a = 0.5
				swapping = true
			elif swapping == true:
				data.swap_items_by_index( swap_item.get_index(), focus_item.get_index() )
				update_inventory( false )
				PauseMenu.update_item_description( focus_item.slot_data.item_data.description )
				swap_item.texture_rect.modulate.a = 1
				swapping = false
			
		if event.is_action_pressed("attack"):
				if swapping == true:
					swap_item.texture_rect.modulate.a = 1
					swapping = false


func clear_inventory() -> void:
	for c in get_children():
		c.set_slot_data( null )
	pass


func update_inventory( apply_focus : bool = true ) -> void:
	clear_inventory()
	
	var inventory_slots : Array[ SlotData ] = data.inventory_slots()
	
	for i in inventory_slots.size():
		var slot : InventorySlotUI = get_child( i )
		slot.set_slot_data( inventory_slots[ i ] )
		connect_item_signals( slot )
	
	# update equipment slots
	var e_slots : Array[ SlotData ] = data.equipment_slots()
	inventory_slot_armor.set_slot_data( e_slots[ 0 ] )
	inventory_slot_weapon.set_slot_data( e_slots[ 1 ] )
	inventory_slot_amulet.set_slot_data( e_slots[ 2 ] )
	inventory_slot_ring.set_slot_data( e_slots[ 3 ] )
	
	if apply_focus:
		get_child( 0 ).grab_focus()


func item_focused() -> void:
	for i in get_child_count():
		if get_child( i ).has_focus():
			focus_index = i
			return
	pass


func on_inventory_changed() -> void:
	update_inventory( false )
	pass


func connect_item_signals( item : InventorySlotUI ) -> void:
	if not item.button_up.is_connected( _on_item_drop ):
		item.button_up.connect( _on_item_drop.bind( item ) )
	
	if not item.mouse_entered.is_connected( _on_item_mouse_entered ):
		item.mouse_entered.connect( _on_item_mouse_entered.bind( item ) )
	
	if not item.mouse_exited.is_connected( _on_item_mouse_exited ):
		item.mouse_exited.connect( _on_item_mouse_exited )
		
	if not item.focus_entered.is_connected( _on_item_focused ):
		item.focus_entered.connect( _on_item_focused.bind(item) )
	pass


func _on_item_drop( item : InventorySlotUI ) -> void:
	if item == null or item == hovered_item or hovered_item == null:
		return
	data.swap_items_by_index( item.get_index(), hovered_item.get_index() )
	update_inventory( false )
	hovered_item.grab_focus()
	pass


func _on_item_mouse_entered( item : InventorySlotUI ) -> void:
	hovered_item = item
	pass


func _on_item_mouse_exited() -> void:
	hovered_item = null
	pass


func _on_item_focused( item : InventorySlotUI ) -> void:
	focus_item = item
	pass
