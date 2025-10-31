class_name EnemyStateDestroy extends EnemyState

const PICKUP = preload("res://Items/ItemPickup/item_pickup.tscn")

@export var anim_name : String = "destroy"
@export var knockback_speed : float = 200.0
@export var decelrate_speed : float = 10.0

@export_category("AI")

var _damage_position : Vector2
var _direction : Vector2


func init() -> void:
	enemy.enemy_destroyed.connect( _on_enemy_destroyed )
	pass
	
	
func enter() -> void:
	enemy.invulnerable = true
	
	_direction = enemy.global_position.direction_to( _damage_position )
	
	enemy.set_direction( _direction )
	enemy.velocity = _direction * -knockback_speed
	
	enemy.update_animation( anim_name )
	enemy.animation_player.animation_finished.connect( _on_animation_finished )
	disable_hurtbox()
	drop_items()
	PlayerManager.reward_xp( enemy.xp_reward )
	pass
	
	
func exit() -> void:
	pass


func process( _delta: float ) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelrate_speed * _delta
	return null
	
	
func physics( _delta: float ) -> EnemyState:
	return null
	
	
func _on_enemy_destroyed( hurt_box : HurtBox ) -> void:
	_damage_position = hurt_box.global_position
	state_machine.change_State( self )
	pass


func _on_animation_finished( _a: String ) -> void:
	enemy.queue_free()


func disable_hurtbox() -> void:
	var hurt_box : HurtBox = enemy.get_node_or_null("HurtBox")
	if hurt_box:
		hurt_box.monitoring = false


func drop_items() -> void:
	if enemy.drops.size() == 0:
		return
		
	for i in enemy.drops.size():
		if enemy.drops[ i ] == null or enemy.drops[ i ].item == null:
			continue
		var drop_count : int = enemy.drops[ i ].get_drop_count()
		for j in drop_count:
			var drop : ItemPickup = PICKUP.instantiate() as ItemPickup
			drop.item_data = enemy.drops[ i ].item
			enemy.get_parent().call_deferred( "add_child", drop )
			drop.global_position = enemy.global_position - enemy.direction
			drop.velocity = enemy.velocity.rotated( randf_range( -1.5, 1.5 ) ) * randf_range( 0.9, 1.5 )
	pass
