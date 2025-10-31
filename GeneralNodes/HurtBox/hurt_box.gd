class_name HurtBox extends Area2D

signal did_damage

@export var damage : int = 1
@export var active : bool = true

func _ready() -> void:
	area_entered.connect( AreaEntered )
	pass
	
	
func _process(_delta) -> void:
	pass


func AreaEntered( area : Area2D ) -> void:
	if area is HitBox:
		did_damage.emit()
		area.TakeDamage( self )
	pass
