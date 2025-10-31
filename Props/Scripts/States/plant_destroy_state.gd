class_name PlantDestroyState extends PlantState

@export var anim_name : String = "destroy"
@onready var collision: CollisionShape2D = $"../../StaticBody2D/CollisionShape2D"

var _damage_position : Vector2

func init() -> void:
	plant.plant_destroyed.connect( _on_plant_destroyed )
	pass
	
	
func enter() -> void:
	plant.invulnerable = true
	collision.set_deferred( "disabled", true )
	plant.update_animation( anim_name )
	plant.animation_player.animation_finished.connect( _on_animation_finished )
	pass
	
	
func exit() -> void:
	pass


func process( _delta: float ) -> PlantState:
	return null
	
	
func physics( _delta: float ) -> PlantState:
	return null
	
	

func _on_plant_destroyed( hurt_box : HurtBox ) -> void:
	_damage_position = hurt_box.global_position
	state_machine.change_State( self )
	pass


func _on_animation_finished( _a: String ) -> void:
	plant.queue_free()
